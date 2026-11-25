#!/bin/bash
# Maus verlässt Symbol + Popup → Popup schließen
if [ "$SENDER" = "mouse.exited.global" ]; then
  source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close clock; exit 0
fi
sketchybar --set "$NAME" label="$(date '+%a %d.%m.  %H:%M')"
