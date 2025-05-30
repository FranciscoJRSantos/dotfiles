#!/usr/bin/env bash

set -euo pipefail

STEP=5.0

# Volume operation
case "${1:-}" in
  up)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ ${STEP}%+
    ;;
  down)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ ${STEP}%-
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  *)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

# Get current volume and mute state
VOLUME_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
RAW_VOLUME=$(echo "$VOLUME_RAW" | awk '{print $2}')
IS_MUTED=$(echo "$VOLUME_RAW" | grep -q MUTED && echo true || echo false)
VOLUME=$(awk "BEGIN { printf \"%d\", $RAW_VOLUME * 100 }")


get_icon() {
  if [[ $IS_MUTED == true ]]; then
    echo "󰝟 "
  elif (( VOLUME <= 33 )); then
    echo ""
  elif (( VOLUME <= 66 )); then
    echo " "
  else
    echo " "
  fi
}

ICON=$(get_icon)

TITLE="Volume"
if [[ $IS_MUTED == true ]]; then
  BODY="$ICON Muted"
  VOLUME=0
else
  BODY="$ICON ${VOLUME}%"
fi

notify-send -a 'sys-notif' -t 500 -h int:value:"$VOLUME" -u low "$TITLE" "$BODY"

