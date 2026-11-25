#!/bin/bash
# Aufnahme-Anzeige: rote Bubble, solange eine macOS-Bildschirmaufnahme läuft. Klick = Aufnahme stoppen.
REC="$CONFIG_DIR/helpers/rec"

if [ "$SENDER" = "mouse.clicked" ]; then
  "$REC" stop
  sleep 0.5
fi

if "$REC" active; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
