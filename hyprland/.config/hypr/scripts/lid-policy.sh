#!/usr/bin/env bash
# Lid policy for the docked/undocked Hyprland workflow.
#   on  (lid closed): docked -> no-op; undocked -> lock and suspend
#   off (lid open):   no-op
# Docked means an enabled HDMI-A-1 or DP-1 monitor is present.
set -euo pipefail

event=${1:-}
dry_run=0
[[ ${2:-} == "--dry-run" ]] && dry_run=1

case "$event" in
    on)
        if hyprctl -j monitors all \
            | jq -e 'any(.[]; (.name == "HDMI-A-1" or .name == "DP-1") and (.disabled == false))' \
            >/dev/null 2>&1; then
            [[ $dry_run -eq 1 ]] && echo "lid closed: docked, no-op"
            exit 0
        fi
        if [[ $dry_run -eq 1 ]]; then
            echo "lid closed: undocked, would lock and suspend"
            exit 0
        fi
        exec noctalia msg session lock_and_suspend
        ;;
    off)
        [[ $dry_run -eq 1 ]] && echo "lid open: no-op"
        exit 0
        ;;
    *)
        echo "usage: $0 {on|off} [--dry-run]" >&2
        exit 2
        ;;
esac
