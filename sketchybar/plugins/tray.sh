#!/bin/bash
# „Tray“: Symbole der Apps, die im Hintergrund laufen (ohne Dock-Symbol oder ohne offenes Fenster).
# Klick auf ein Symbol öffnet/aktiviert die App. Baut die Bubble nur neu, wenn sich die Liste ändert.
SB=/opt/homebrew/bin/sketchybar
# Symbol-Stil: gruvbox (einfarbig cremig) | gray (Graustufen) | color (Original-App-Symbole)
STYLE=gruvbox
ICONS="$HOME/.cache/sketchybar-tray/$STYLE"
CACHE=/tmp/sketchybar-tray-list
LOCK=/tmp/sketchybar-tray.lock

# Nach einer Fensteränderung beendet sich die App oft erst kurz danach → 1,5 s später nochmal prüfen
if [ "$SENDER" = "rift_workspace_changed" ]; then
  ( sleep 1.5; SENDER=recheck "$0" ) >/dev/null 2>&1 &
fi

# Immer nur ein Durchlauf gleichzeitig (sonst geraten Symbole und Abstand durcheinander)
for _ in $(seq 30); do mkdir "$LOCK" 2>/dev/null && break; sleep 0.1; done
[ -d "$LOCK" ] || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

LIST="$("$CONFIG_DIR/helpers/bg_apps")"
[ -f "$CACHE" ] && [ "$STYLE|$LIST" = "$(cat "$CACHE")" ] && $SB --query tray >/dev/null 2>&1 && exit 0
echo "$STYLE|$LIST" > "$CACHE"

source "$CONFIG_DIR/colors.sh"

# Alles in EINEM sketchybar-Aufruf: alte Tray entfernen, neu aufbauen (Reihenfolge von rechts nach links)
ARGS=(--remove '/tray\.app\..*/' --remove tray)
if [ -n "$LIST" ]; then
  ARGS+=(--add item tray.app.gap right --set tray.app.gap width=6 icon.drawing=off label.drawing=off)
  ITEMS=()
  i=0
  while IFS=$'\t' read -r id name; do
    [ -z "$id" ] && continue
    if [ "$STYLE" = color ]; then
      IMG="app.$id"; SCALE=0.6
    else
      mkdir -p "$ICONS"; IMG="$ICONS/$id.png"; SCALE=0.3
      [ -f "$IMG" ] || "$CONFIG_DIR/helpers/tray_icon" "$id" "$STYLE" "$IMG" || { IMG="app.$id"; SCALE=0.6; }
    fi
    ARGS+=(--add item tray.app.$i right
           --set tray.app.$i label.drawing=off icon.drawing=on icon=""
                 icon.background.image="$IMG" icon.background.image.scale=$SCALE
                 icon.background.drawing=on icon.padding_left=0 icon.padding_right=0
                 padding_left=2 padding_right=2 click_script="open -b '$id'")
    ITEMS+=(tray.app.$i)
    i=$((i + 1))
  done <<< "$LIST"
  # etwas mehr Luft am Bubble-Rand (rechts = erstes Symbol, links = letztes)
  ARGS+=(--set "${ITEMS[0]}" padding_right=10
         --set "${ITEMS[$((${#ITEMS[@]}-1))]}" padding_left=10
         --add bracket tray "${ITEMS[@]}"
         --set tray background.color=$BG1 background.corner_radius=9 background.height=28
                    background.border_color=0xff504945 background.border_width=1 background.drawing=on)
fi
$SB "${ARGS[@]}" >/dev/null 2>&1
