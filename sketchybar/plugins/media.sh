#!/bin/bash
# Medien-Bubble: zeigt, was gerade läuft. Klick = Play/Pause, Scrollen = nächster/vorheriger Titel.
source "$CONFIG_DIR/colors.sh"
KEY="$CONFIG_DIR/helpers/media_key"

case "$SENDER" in
  media_change)
    STATE="$(echo "$INFO" | /usr/bin/python3 -c 'import sys,json;print((json.load(sys.stdin).get("state") or ""))' 2>/dev/null)"
    TITLE="$(echo "$INFO" | /usr/bin/python3 -c 'import sys,json;print((json.load(sys.stdin).get("title") or ""))' 2>/dev/null)"
    ARTIST="$(echo "$INFO" | /usr/bin/python3 -c 'import sys,json;print((json.load(sys.stdin).get("artist") or ""))' 2>/dev/null)"

    if [ -z "$TITLE" ]; then
      sketchybar --set "$NAME" drawing=off
      exit 0
    fi
    TEXT="$TITLE"
    [ -n "$ARTIST" ] && TEXT="$ARTIST – $TITLE"
    [ ${#TEXT} -gt 40 ] && TEXT="${TEXT:0:39}…"

    if [ "$STATE" = "playing" ]; then
      sketchybar --set "$NAME" drawing=on icon=󰎆 icon.color=$GREEN label="$TEXT" label.color=$FG
    else
      sketchybar --set "$NAME" drawing=on icon=󰏤 icon.color=$GRAY label="$TEXT" label.color=$GRAY
    fi
    ;;
  mouse.clicked)
    "$KEY" play
    ;;
  mouse.scrolled)
    LOCK=/tmp/sketchybar-media.lock
    mkdir "$LOCK" 2>/dev/null || exit 0
    trap 'sleep 0.4; rmdir "$LOCK"' EXIT
    if [ "${SCROLL_DELTA:-0}" -gt 0 ]; then "$KEY" next; else "$KEY" prev; fi
    ;;
esac
