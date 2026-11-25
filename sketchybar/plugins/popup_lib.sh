#!/bin/bash
# Gemeinsame Hilfsfunktionen für Popups (WLAN nutzt noch eigene Kopie).
source "$CONFIG_DIR/colors.sh"
SB=/opt/homebrew/bin/sketchybar
FONT="JetBrainsMono Nerd Font Mono"

# popup_close <parent>
popup_close() {
  rm -f "/tmp/sketchybar-$1-popup-open"
  $SB --set "$1" popup.drawing=off
  $SB --remove "/$1\\.p\\..*/" >/dev/null 2>&1
}

# popup_toggle <parent> <fill-funktion>  → gibt 0 zurück, wenn geöffnet wurde
popup_toggle() {
  local state="/tmp/sketchybar-$1-popup-open"
  if [ -e "$state" ]; then
    popup_close "$1"
    return 1
  fi
  # andere offene Popups schließen
  for f in /tmp/sketchybar-*-popup-open; do
    [ -e "$f" ] || continue
    p="${f#/tmp/sketchybar-}"; p="${p%-popup-open}"
    [ "$p" = "$1" ] || popup_close "$p"
  done
  touch "$state"
  $SB --remove "/$1\\.p\\..*/" >/dev/null 2>&1
  "$2"
  $SB --set "$1" popup.drawing=on
}

# popup_row <parent> <name> <icon> <label> [click] [color]
popup_row() {
  $SB --add item "$1.p.$2" popup."$1" \
      --set "$1.p.$2" icon="$3" label="$4" click_script="${5:-}" \
                      icon.font="$FONT:Bold:14.0" label.font="$FONT:Bold:13.0" \
                      icon.color="${6:-$FG}" label.color="${6:-$FG}" \
                      icon.padding_left=10 label.padding_right=12 \
                      icon.drawing=$([ -n "$3" ] && echo on || echo off) \
                      background.drawing=off >/dev/null
}

# popup_style <parent>  (einmalig in sketchybarrc)
popup_style() {
  $SB --set "$1" popup.align=right popup.y_offset=4 popup.height=26 \
                 popup.background.color=$BG1 \
                 popup.background.corner_radius=9 \
                 popup.background.border_color=0xff504945 \
                 popup.background.border_width=1
}
