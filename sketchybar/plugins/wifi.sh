#!/bin/bash
# Zeigt nur verbunden/getrennt (den WLAN-Namen gibt macOS ohne Ortungsfreigabe nicht heraus)
source "$CONFIG_DIR/colors.sh"

# Maus verlässt Symbol + Popup → Popup schließen
if [ "$SENDER" = "mouse.exited.global" ]; then
  "$CONFIG_DIR/plugins/wifi_popup.sh" close
  exit 0
fi

if ipconfig getifaddr en0 >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon="󰖩" icon.color=$FG label.drawing=off
else
  sketchybar --set "$NAME" icon="󰖪" icon.color=$GRAY label.drawing=off
fi
