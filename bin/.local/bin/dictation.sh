#!/usr/bin/env bash
# Push-to-talk dictation through hyprwhspr.
#
# Bound in hyprland.lua:
#   Super+M press   -> dictation.sh start
#   Super+M release -> dictation.sh release
#   Super+Escape    -> dictation.sh cancel
#
# hyprwhspr runs with external_bindings = true, so Hyprland owns the keys and
# this script drives the daemon. It only maps actions to the hyprwhspr CLI;
# transcription, language detection and injection stay in the daemon.
#
# Extra arguments are passed through, so a language-specific bind can use:
#   dictation.sh start --lang pt
#
# Environment overrides:
#   HYPRWHSPR_BIN      hyprwhspr executable (default: ~/.local/bin/hyprwhspr,
#                      then PATH)
#
# `release` is best-effort: pressing it with nothing recording must not raise a
# notification. `start`, `cancel` and `toggle` failures are loud, because a
# silent no-op is indistinguishable from a dead keybinding (an idle `cancel`
# still exits 0, so a stray press is not noisy).
set -euo pipefail

usage() {
    cat <<'EOF'
usage: dictation.sh <start|release|cancel|toggle> [hyprwhspr args...]

  start    begin recording (extra args go to `hyprwhspr record start`)
  release  key-up: stop, or latch a long hold in push-to-talk mode
  cancel   discard the recording without transcribing
  toggle   start if idle, stop if recording
EOF
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a dictation "Dictation" "$1" || true
    fi
}

# hyprwhspr lives in ~/.local/bin, which is not on Hyprland's exec PATH.
resolve_bin() {
    if [[ -n ${HYPRWHSPR_BIN:-} && -x ${HYPRWHSPR_BIN} ]]; then
        printf '%s\n' "$HYPRWHSPR_BIN"
    elif [[ -x $HOME/.local/bin/hyprwhspr ]]; then
        printf '%s\n' "$HOME/.local/bin/hyprwhspr"
    elif command -v hyprwhspr >/dev/null 2>&1; then
        command -v hyprwhspr
    else
        return 1
    fi
}

main() {
    local action=${1:-}
    if [[ $# -gt 0 ]]; then
        shift
    fi

    case $action in
        start | release | cancel | toggle) ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac

    local bin
    if ! bin=$(resolve_bin); then
        local msg="dictation: hyprwhspr not found (install: https://hyprwhspr.com)"
        printf '%s\n' "$msg" >&2
        notify "$msg"
        exit 1
    fi

    # deferred: the recording_control FIFO replies faster than a Python CLI
    # start (~0.3 s). Switch when the key-to-beep delay becomes noticeable.
    local rc=0
    "$bin" record "$action" "$@" || rc=$?
    ((rc == 0)) && exit 0

    case $action in
        start | cancel | toggle)
            notify "dictation: hyprwhspr record $action failed (is hyprwhspr.service running?)"
            ;;
    esac
    exit "$rc"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
