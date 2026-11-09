#!/usr/bin/env bash
# Tests for bin/.local/bin/read-selection.sh.
# Dependency-free on purpose: bash + coreutils, no bats.
# Run: bash tests/read-selection.sh
set -uo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script=$repo/bin/.local/bin/read-selection.sh

if [[ ! -f $script ]]; then
    echo "FAIL $script is missing" >&2
    exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/stubs" "$work/out" "$work/run"

pass=0
fail=0
ok() { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
nok() {
    fail=$((fail + 1))
    printf 'FAIL %s\n' "$1"
    [[ $# -gt 1 ]] && printf '     %s\n' "$2"
}
assert_eq() { # name expected actual
    if [[ $2 == "$3" ]]; then ok "$1"; else nok "$1" "expected [$2] got [$3]"; fi
}
assert_contains() { # name needle haystack
    if [[ $3 == *"$2"* ]]; then ok "$1"; else nok "$1" "[$2] not in [$3]"; fi
}

stub() { # name body
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"$work/stubs/$1"
    chmod +x "$work/stubs/$1"
}

# shellcheck disable=SC2016 # stub bodies expand at run time, not now
stub wl-paste 'case " $* " in
    *" --primary "*) printf "%s" "${STUB_PRIMARY:-}" ;;
    *) printf "%s" "${STUB_CLIP:-}" ;;
esac'
# shellcheck disable=SC2016
stub piper 'printf "%s\n" "$*" >"$OUT/piper.args"; cat >"$OUT/piper.stdin"'
# shellcheck disable=SC2016
stub paplay 'printf "%s\n" "$*" >>"$OUT/play.args"; cat >"$OUT/play.stdin"'
# Tests must never raise real desktop notifications.
# shellcheck disable=SC2016
stub notify-send 'printf "%s\n" "$*" >>"$OUT/notify"'
# shellcheck disable=SC2016
stub curl 'n=$(($(cat "$OUT/curl.count" 2>/dev/null || echo 0) + 1))
printf "%s\n" "$n" >"$OUT/curl.count"
printf "%s\n" "$*" >>"$OUT/curl.args"
cat >>"$OUT/curl.stdin"
case "$*" in
    *piper.test*)
        [[ ${FAIL_ON:-0} == "$n" ]] && exit 22
        printf "RIFFfakewav"
        ;;
    *) exit 7 ;;
esac'

reset_out() { rm -f "$work"/out/*; }

# Run one script function in a subshell so the script's `set -e` cannot leak.
call() { # fn [stdin]
    # shellcheck disable=SC1090 # path is resolved at run time
    (source "$script" && "$1") <<<"${2:-}"
}

# Run one script function with stubbed wl-paste/piper/paplay on PATH.
call_with() { # fn primary clip
    # shellcheck disable=SC2030,SC2034
    (export STUB_PRIMARY=$2 STUB_CLIP=$3 OUT=$work/out
        PIPER_BIN=${PIPER_BIN:-$work/stubs/piper}
        PIPER_URL=${PIPER_URL:-http://127.0.0.1:9}
        XDG_RUNTIME_DIR=$work/run
        PATH="$work/stubs:$PATH"
        # shellcheck disable=SC1090
        source "$script"
        "$1") </dev/null
}

# Run the whole script's main().
run_main() { # primary clip
    call_with main "$1" "$2" 2>"$work/out/stderr"
}

# Run the script's --stop mode against the sandbox runtime dir.
run_stop() {
    # shellcheck disable=SC2031
    env XDG_RUNTIME_DIR="$work/run" OUT="$work/out" PATH="$work/stubs:$PATH" \
        bash -c "source '$script'; main --stop" </dev/null >/dev/null 2>&1
}

# --- preprocess ------------------------------------------------------------

assert_eq "preprocess strips markdown syntax" \
    $'Title\nSome bold and italic and code.\nSee the docs.' \
    "$(call preprocess $'# Title\nSome **bold** and *italic* and `code`.\nSee [the docs](https://example.com).')"

assert_eq "preprocess drops fenced code blocks" \
    $'before\nafter' \
    "$(call preprocess $'before\n```bash\nrm -rf /\n```\nafter')"

assert_eq "preprocess strips box drawing" \
    'hi' \
    "$(call preprocess $'┌─────┐\n│ hi  │\n└─────┘')"

assert_eq "preprocess strips ANSI escapes" \
    'red text' \
    "$(call preprocess "$(printf '\x1b[1;31mred\x1b[0m text')")"

assert_eq "preprocess strips bracketed-paste markers" \
    'yz' \
    "$(call preprocess "$(printf 'y\x1b[200~z\x1b[201~')")"

assert_eq "preprocess strips ST-terminated OSC hyperlinks" \
    'abc' \
    "$(call preprocess "$(printf 'a\x1b]8;;http://example.com\x1b\\b\x1b]8;;\x1b\\c')")"

assert_eq "preprocess strips BEL-terminated OSC titles" \
    'ab' \
    "$(call preprocess "$(printf 'a\x1b]0;title\x07b')")"

assert_eq "preprocess replaces table pipes with spaces" \
    'a b' \
    "$(call preprocess 'a | b')"

assert_eq "split_chunks breaks on sentence endings" \
    $'One.\nTwo!\nThree?' \
    "$(call split_chunks 'One. Two! Three?')"

assert_eq "split_chunks folds runaway sentences" \
    '2' \
    "$(printf 'word %.0s' {1..60} | bash -c "source '$script'; split_chunks" | awk 'END { print NR }')"

assert_eq "split_chunks drops blank lines" \
    'Only line' \
    "$(call split_chunks $'\n\nOnly line\n\n')"

# --- selection -------------------------------------------------------------

assert_eq "selection prefers PRIMARY" \
    'primary text' \
    "$(call_with selection 'primary text' 'clipboard text')"

assert_eq "selection falls back to clipboard" \
    'clipboard text' \
    "$(call_with selection '  ' 'clipboard text')"

assert_eq "selection is empty with no text anywhere" \
    '' \
    "$(call_with selection '' '')"

# --- main ------------------------------------------------------------------

reset_out
run_main $'# Header\nSome **bold** text' '' && rc=0 || rc=$?
assert_eq "main exits 0" '0' "$rc"
assert_eq "main feeds preprocessed text to piper" \
    $'Header\nSome bold text' \
    "$(cat "$work/out/piper.stdin" 2>/dev/null)"
assert_contains "main plays raw s16le on the default rate" \
    '--raw --rate=22050 --format=s16le --channels=1' \
    "$(cat "$work/out/play.args" 2>/dev/null)"
assert_contains "main passes the voice model to piper" \
    '--model en_US-ryan-high' \
    "$(cat "$work/out/piper.args" 2>/dev/null)"
assert_contains "main asks piper for raw audio" \
    '--output-raw' \
    "$(cat "$work/out/piper.args" 2>/dev/null)"

reset_out
PIPER_VOICE=pt_BR-faber-medium PIPER_SAMPLE_RATE=16000 run_main 'texto' '' && rc=0 || rc=$?
assert_eq "main honours the voice override" '0' "$rc"
assert_contains "main passes the overridden voice" '--model pt_BR-faber-medium' \
    "$(cat "$work/out/piper.args" 2>/dev/null)"
assert_contains "main plays at the overridden rate" '--rate=16000' \
    "$(cat "$work/out/play.args" 2>/dev/null)"

reset_out
run_main '' '' && rc=0 || rc=$?
assert_eq "main exits 0 with no selection" '0' "$rc"
assert_eq "main does not call piper with no selection" '' \
    "$(cat "$work/out/piper.args" 2>/dev/null)"

reset_out
run_main '' 'clipboard fallback' && rc=0 || rc=$?
assert_eq "main speaks the clipboard when PRIMARY is empty" '0' "$rc"
assert_eq "main feeds the clipboard text to piper" \
    $'clipboard fallback' \
    "$(cat "$work/out/piper.stdin" 2>/dev/null)"

reset_out
PIPER_BIN=/nonexistent/piper run_main 'text' '' && rc=0 || rc=$?
assert_eq "main fails when piper is missing" '1' "$rc"
assert_contains "main explains the missing piper" 'not found' \
    "$(cat "$work/out/stderr" 2>/dev/null)"

reset_out
mkdir -p "$work/home/.local/bin"
cp "$work/stubs/piper" "$work/home/.local/bin/piper"
env STUB_PRIMARY='home fallback' STUB_CLIP='' OUT="$work/out" HOME="$work/home" \
    PIPER_URL=http://127.0.0.1:9 PATH="$work/stubs:/usr/bin:/bin" \
    bash -c "source '$script'; main" </dev/null >/dev/null 2>&1 && rc=0 || rc=$?
assert_eq "main finds piper under ~/.local/bin when PATH lacks it" '0' "$rc"
assert_eq "the home-resolved piper receives the text" 'home fallback' \
    "$(cat "$work/out/piper.stdin" 2>/dev/null)"

reset_out
PIPER_URL=http://piper.test run_main 'server text' '' && rc=0 || rc=$?
assert_eq "main uses the server when one answers" '0' "$rc"
assert_eq "the server path does not start piper" '' \
    "$(cat "$work/out/piper.args" 2>/dev/null)"
assert_contains "the server path plays a wav file" '.wav' \
    "$(cat "$work/out/play.args" 2>/dev/null)"
assert_eq "the server path does not use raw playback" '' \
    "$(grep -o -- '--raw' "$work/out/play.args" 2>/dev/null)"
assert_contains "the server request carries the text" '"text":"server text"' \
    "$(cat "$work/out/curl.stdin" 2>/dev/null)"
assert_contains "the server request carries the voice" '"voice":"en_US-ryan-high"' \
    "$(cat "$work/out/curl.stdin" 2>/dev/null)"
assert_contains "the server request goes to /synthesize" 'piper.test/synthesize' \
    "$(cat "$work/out/curl.args" 2>/dev/null)"

reset_out
PIPER_URL=http://piper.test run_main 'One. Two.' '' && rc=0 || rc=$?
assert_eq "multi-chunk playback exits 0" '0' "$rc"
assert_eq "multi-chunk playback requests both sentences" '2' \
    "$(wc -l <"$work/out/curl.args" 2>/dev/null)"
assert_eq "multi-chunk playback plays both chunks" '2' \
    "$(wc -l <"$work/out/play.args" 2>/dev/null)"

reset_out
FAIL_ON=2 PIPER_URL=http://piper.test run_main 'One. Two.' '' && rc=0 || rc=$?
assert_eq "mid-stream failure still exits 0 via the fallback" '0' "$rc"
assert_eq "mid-stream failure retries only the unheard chunk" 'Two.' \
    "$(cat "$work/out/piper.stdin" 2>/dev/null)"
assert_eq "mid-stream failure does not replay the first chunk" '0' \
    "$(grep -c 'One\.' "$work/out/piper.stdin" 2>/dev/null || true)"

reset_out
run_main 'pid text' '' >/dev/null
assert_eq "main removes its pidfile when the read ends" '' \
    "$(cat "$work/run/read-selection.pid" 2>/dev/null)"

run_stop
assert_eq "--stop with no running read exits 0" '0' "$?"

bash -c 'exec -a read-selection.sh sleep 30' &
victim=$!
sleep 0.2
printf '%s\n' "$victim" >"$work/run/read-selection.pid"
run_stop
sleep 0.2
if kill -0 "$victim" 2>/dev/null; then
    nok "--stop terminates the running read"
    kill "$victim" 2>/dev/null || true
else
    ok "--stop terminates the running read"
fi
assert_eq "--stop removes the pidfile" '' \
    "$(cat "$work/run/read-selection.pid" 2>/dev/null)"

bash -c 'exec -a read-selection.sh sleep 30' &
victim=$!
sleep 0.2
printf '%s\n' "$victim" >"$work/run/read-selection.pid"
reset_out
run_main 'new text' '' >/dev/null
sleep 0.2
if kill -0 "$victim" 2>/dev/null; then
    nok "a new read stops the previous one"
    kill "$victim" 2>/dev/null || true
else
    ok "a new read stops the previous one"
fi

# shellcheck disable=SC1090
(source "$script"; require_player) >/dev/null 2>&1
assert_eq "require_player accepts an installed player" '0' "$?"

env PATH=/nonexistent /bin/bash -c "source '$script'; require_player" \
    >/dev/null 2>"$work/out/noplayer.err"
assert_eq "require_player fails when paplay is missing" '1' "$?"
assert_contains "require_player names the package to install" 'pulseaudio-utils' \
    "$(cat "$work/out/noplayer.err" 2>/dev/null)"

# --- summary ---------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
