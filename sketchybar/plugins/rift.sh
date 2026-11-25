#!/bin/bash
# Hebt den aktiven Rift-Workspace hervor, dimmt leere Workspaces.
source "$CONFIG_DIR/colors.sh"

/opt/homebrew/bin/rift-cli query workspaces 2>/dev/null | /usr/bin/python3 -c '
import json, sys
for w in json.load(sys.stdin):
    print(w["index"], int(w["is_active"]), w["window_count"])
' | while read -r idx active count; do
  if [ "$active" = "1" ]; then
    sketchybar --set ws.$idx background.drawing=on background.color=$YELLOW icon.color=$BG
  elif [ "$count" -gt 0 ]; then
    sketchybar --set ws.$idx background.drawing=off icon.color=$FG
  else
    sketchybar --set ws.$idx background.drawing=off icon.color=$GRAY
  fi
done
