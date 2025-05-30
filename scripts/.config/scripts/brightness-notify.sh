#!/usr/bin/env bash

set -euo pipefail

STEP=5.0

# Brightness operation
case "${1:-}" in
  up)
    brightnessctl set +${STEP}%
    ;;
  down)
    brightnessctl set ${STEP}-%
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac

# Get current brightness
BRIGHTNESS=$(brightnessctl get)
MAX_BRIGHTNESS=$(brightnessctl max)
PERCENT=$(awk "BEGIN { printf \"%d\", ($BRIGHTNESS / $MAX_BRIGHTNESS) * 100 }")

# Icon selection
if (( PERCENT <= 33 )); then
  ICON=""
elif (( PERCENT <= 66 )); then
  ICON=""
else
  ICON=""
fi

TITLE="Brightness"
BODY="$ICON ${PERCENT}%"

# Send persistent notification with a bar
notify-send -a 'sys-notif' -t 500 -h int:value:"$PERCENT" -u low "$TITLE" "$BODY"

