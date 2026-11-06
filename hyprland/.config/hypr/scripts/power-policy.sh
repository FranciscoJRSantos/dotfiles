#!/usr/bin/env bash
# Power policy for the docked/undocked Hyprland workflow.
#   on   (lid closed): docked -> no-op; undocked -> lock and suspend
#   off  (lid open):   no-op
#   idle (15 min):     docked -> no-op; undocked -> suspend (lock already happened)
#
# Docked means AC online AND lid closed (decision D2). The previous signal (an
# enabled HDMI-A-1 or DP-1 monitor) was unsafe: the home OLED disconnects
# entirely when it powers off, so a docked laptop looked undocked and could
# suspend itself on idle.
set -euo pipefail

event=${1:-}
dry_run=0
[[ ${2:-} == "--dry-run" ]] && dry_run=1

# Read from the environment when set, so --dry-run can exercise both branches
# without unplugging anything or closing the lid.
ac_online=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1 || true)
lid_state=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $2}' | head -1 || true)
ac_online=${POWER_POLICY_AC_ONLINE:-$ac_online}
lid_state=${POWER_POLICY_LID_STATE:-$lid_state}

is_docked() {
    [[ $ac_online == 1 && $lid_state == closed ]]
}

case "$event" in
    on)
        if is_docked; then
            [[ $dry_run -eq 1 ]] && echo "lid closed: docked, no-op"
            exit 0
        fi
        if [[ $dry_run -eq 1 ]]; then
            echo "lid closed: undocked, would lock and suspend"
            exit 0
        fi
        exec noctalia msg session lock-and-suspend
        ;;
    off)
        [[ $dry_run -eq 1 ]] && echo "lid open: no-op"
        exit 0
        ;;
    idle)
        if is_docked; then
            [[ $dry_run -eq 1 ]] && echo "idle: docked, no-op"
            exit 0
        fi
        if [[ $dry_run -eq 1 ]]; then
            echo "idle: undocked, would suspend"
            exit 0
        fi
        exec systemctl suspend
        ;;
    *)
        echo "usage: $0 {on|off|idle} [--dry-run]" >&2
        exit 2
        ;;
esac
