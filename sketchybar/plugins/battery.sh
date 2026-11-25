#!/bin/bash
# Maus verlässt Symbol + Popup → Popup schließen
if [ "$SENDER" = "mouse.exited.global" ]; then
  source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close battery; exit 0
fi
source "$CONFIG_DIR/colors.sh"

BATT="$(pmset -g batt)"
PERCENT="$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$PERCENT" ] && exit 0

COLOR=$FG
case "$PERCENT" in
  9[0-9]|100) ICON="󰁹" ;;
  [6-8][0-9]) ICON="󰂀" ;;
  [3-5][0-9]) ICON="󰁾" ;;
  [1-2][0-9]) ICON="󰁻"; COLOR=$ORANGE ;;
  *)          ICON="󰂎"; COLOR=$RED ;;
esac
echo "$BATT" | grep -q 'AC Power' && ICON="󰂄" && COLOR=$GREEN

sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${PERCENT}%"
