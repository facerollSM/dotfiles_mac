#!/bin/bash
# Bluetooth-Symbol: aus / an / verbunden. Braucht blueutil (brew install blueutil).
if [ "$SENDER" = "mouse.exited.global" ]; then
  source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close bluetooth; exit 0
fi
source "$CONFIG_DIR/colors.sh"
BU=/opt/homebrew/bin/blueutil

if [ ! -x "$BU" ]; then
  sketchybar --set "$NAME" icon=󰂲 icon.color=$GRAY label.drawing=off
  exit 0
fi

if [ "$($BU -p)" = "0" ]; then
  sketchybar --set "$NAME" icon=󰂲 icon.color=$GRAY label.drawing=off
elif [ -n "$($BU --connected 2>/dev/null)" ]; then
  sketchybar --set "$NAME" icon=󰂱 icon.color=$AQUA label.drawing=off
else
  sketchybar --set "$NAME" icon=󰂯 icon.color=$FG label.drawing=off
fi
