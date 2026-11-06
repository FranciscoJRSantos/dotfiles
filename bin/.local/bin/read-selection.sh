#!/usr/bin/env bash
# Read the PRIMARY selection aloud with Piper (clipboard as fallback).
#
# Bound to Super+R in hyprland.lua. PRIMARY comes first because Ghostty
# publishes copy-on-select by default, so highlighting is enough; the
# clipboard is the fallback for apps that never set PRIMARY.
#
# Environment overrides:
#   PIPER_VOICE        voice name              (default en_US-ryan-high)
#   PIPER_DATA_DIR     voice directory         (default $XDG_DATA_HOME/piper)
#   PIPER_SAMPLE_RATE  raw sample rate in Hz   (default 22050, the high-voice rate)
#   PIPER_BIN          piper executable        (default ~/.local/bin/piper, else PATH)
#   PIPER_URL          TTS server base URL      (default http://127.0.0.1:5000)
#
# `read-selection.sh --stop` silences an in-flight read (bound to Super+Shift+R);
# starting a new read does the same, so presses never stack.
#
# The resident HTTP server (systemd user unit piper-tts.service) keeps the voice
# model loaded. Direct invocation is the fallback: it costs ~3s of model load.
set -euo pipefail

# Multibyte classes below (box drawing) must match whole characters; a C/POSIX
# locale makes GNU sed match bytes and corrupt unrelated text instead.
export LC_ALL=C.UTF-8

VOICE=${PIPER_VOICE:-en_US-ryan-high}
DATA_DIR=${PIPER_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/piper}
SAMPLE_RATE=${PIPER_SAMPLE_RATE:-22050}
SERVER_URL=${PIPER_URL:-http://127.0.0.1:5000}
SERVER_CHUNKS=()
SERVER_SPOKEN=0
PID_FILE=${XDG_RUNTIME_DIR:-/tmp}/read-selection.pid
# piper lives in ~/.local/bin, which is not guaranteed on Hyprland's PATH.
if [[ -n ${PIPER_BIN:-} ]]; then
    PIPER=$PIPER_BIN
elif [[ -x $HOME/.local/bin/piper ]]; then
    PIPER=$HOME/.local/bin/piper
else
    PIPER=piper
fi

# Terminate every descendant of a pid (pkill -P only reaches direct children,
# and killing a pipeline's subshell does not kill the players inside it).
kill_tree() {
    local child
    for child in $(pgrep -P "$1" 2>/dev/null); do
        kill_tree "$child"
        kill -TERM "$child" 2>/dev/null || true
    done
}

# Stop the read started by another invocation, if one is still running.
stop_playback() {
    local pid
    [[ -f $PID_FILE ]] || return 0
    pid=$(cat "$PID_FILE" 2>/dev/null || true)
    rm -f "$PID_FILE"
    [[ -n $pid ]] || return 0
    # Guard against a stale pid that now belongs to something else.
    tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null | grep -q read-selection || return 0
    kill -TERM "$pid" 2>/dev/null || true
}

# Play in the background and wait, so a TERM can interrupt the wait itself
# (bash defers traps while a foreground child runs).
play_file() {
    paplay "$1" &
    wait $!
}

# Print the text to speak: PRIMARY when it has content, else the clipboard.
selection() {
    local text
    text=$(wl-paste --primary --no-newline 2>/dev/null || true)
    if [[ -z ${text//[[:space:]]/} ]]; then
        text=$(wl-paste --no-newline 2>/dev/null || true)
    fi
    printf '%s\n' "$text"
}

# Strip terminal and markdown noise so Piper never reads syntax aloud.
# Reads stdin, writes cleaned text.
preprocess() {
    awk '
        /^[[:space:]]*(```|~~~)/ { fenced = !fenced; next }
        fenced { next }
        { print }
    ' |
        sed -E '
            s/\x1b\[[0-9;?]*[[:alpha:]@~]//g
            s/\x1b\][^\x1b\x07]*(\x07|\x1b\\)//g
            s/!\[[^]]*\]\([^)]*\)//g
            s/\[([^]]*)\]\([^)]*\)/\1/g
            s/`+//g
            s/\*\*//g
            s/__//g
            s/~~//g
            s/\*//g
            s/^[[:space:]]*#+[[:space:]]*//
            s/^[[:space:]]*>[[:space:]]*//
            s/^[[:space:]]*([-+]|[0-9]+\.)[[:space:]]+//
            s/^[[:space:]]*[-_]{3,}[[:space:]]*$//
            s/\|/ /g
            s/[─━│┃┌┏┐┓└┗┘┛├┣┤┫┬┳┴┻┼╋╭╮╯╰▏▕]//g
            s/[[:space:]]{2,}/ /g
            s/^[[:space:]]+//
            s/[[:space:]]+$//
            /^$/d
        '
}

# Sentence-sized chunks so playback starts after the first one is synthesized
# instead of waiting for the whole selection. `fold` caps runaway sentences.
split_chunks() {
    sed -E 's/([.!?])[[:space:]]+/\1\n/g' | fold -s -w 200 | sed '/^[[:space:]]*$/d'
}

# Synthesize one chunk to a file through the resident server.
synth_to() {
    jq -cn --arg text "$2" --arg voice "$VOICE" '{text: $text, voice: $voice}' |
        curl -fs --max-time 120 -H 'Content-Type: application/json' --data-binary @- \
            "$SERVER_URL/synthesize" >"$1"
}

# Speak through the resident server. One chunk is synthesized at a time, the
# next while the previous plays: playback starts after the first sentence and
# stays gapless. Synthesizing chunks concurrently only slows the first one
# down (they compete for the same CPU).
speak_via_server() {
    command -v curl >/dev/null 2>&1 || return 1
    command -v jq >/dev/null 2>&1 || return 1

    local text=$1 tmp i last rc=0
    local -a chunks pids
    mapfile -t chunks < <(printf '%s\n' "$text" | split_chunks)
    ((${#chunks[@]})) || return 1

    tmp=$(mktemp -d) || return 1
    last=$((${#chunks[@]} - 1))
    # Exposed so speak() can retry only the chunks that were never heard.
    SERVER_CHUNKS=("${chunks[@]}")
    SERVER_SPOKEN=0

    synth_to "$tmp/0.wav" "${chunks[0]}" &
    pids[0]=$!

    for ((i = 1; i <= last; i++)); do
        if ! wait "${pids[i - 1]}" || [[ ! -s $tmp/$((i - 1)).wav ]]; then
            rc=1
            break
        fi
        synth_to "$tmp/$i.wav" "${chunks[$i]}" &
        pids[i]=$!
        play_file "$tmp/$((i - 1)).wav" || {
            rc=1
            break
        }
        SERVER_SPOKEN=$i
    done

    if ((rc == 0)); then
        if ! wait "${pids[last]}" || [[ ! -s $tmp/$last.wav ]] || ! play_file "$tmp/$last.wav"; then
            rc=1
        else
            SERVER_SPOKEN=$((last + 1))
        fi
    fi

    if ((rc != 0)); then
        # Do not leave the newest synthesis running while the fallback needs
        # the CPU for its own model load.
        kill "${pids[i]:-}" 2>/dev/null || true
    fi

    rm -rf "$tmp"
    return $rc
}

# Fallback when the server is down: Piper reloads the voice model (~3s).
speak_direct() {
    if ! command -v "$PIPER" >/dev/null 2>&1; then
        local msg="read-selection: $PIPER not found (install: uv tool install piper-tts)"
        printf '%s\n' "$msg" >&2
        command -v notify-send >/dev/null 2>&1 && notify-send -a read-selection "Read aloud" "$msg"
        return 1
    fi
    printf '%s\n' "$1" |
        "$PIPER" --model "$VOICE" --data-dir "$DATA_DIR" --output-raw |
        paplay --raw --rate="$SAMPLE_RATE" --format=s16le --channels=1 &
    wait $!
}

speak() {
    # deferred: overlapping invocations stack audio. A singleton lock or an
    # interrupt bind belongs with a future interrupt slice.
    local rc=0
    speak_via_server "$1" || rc=$?
    ((rc == 0)) && return 0

    # A failure after some chunks played must not replay them from the start.
    if ((SERVER_SPOKEN > 0)); then
        speak_direct "$(printf '%s\n' "${SERVER_CHUNKS[@]:SERVER_SPOKEN}")"
        return
    fi
    speak_direct "$1"
}

main() {
    if [[ ${1:-} == "--stop" ]]; then
        stop_playback
        exit 0
    fi

    local text
    text=$(selection | preprocess)
    # deferred: no size cap; a multi-megabyte selection is spoken in full.
    # Truncate the head if a huge clipboard ever becomes a real case.
    if [[ -z ${text//[[:space:]]/} ]]; then
        exit 0
    fi

    stop_playback
    printf '%s\n' "$$" >"$PID_FILE"
    # Only remove the pidfile if it still describes this process, otherwise a
    # late trap from an interrupted read would delete its successor's file.
    trap 'trap - TERM INT; kill_tree $$
        [[ $(cat "$PID_FILE" 2>/dev/null) == "$$" ]] && rm -f "$PID_FILE"; exit 130' TERM INT
    trap '[[ $(cat "$PID_FILE" 2>/dev/null) == "$$" ]] && rm -f "$PID_FILE"' EXIT

    speak "$text"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
