#!/bin/bash
# „Tray“: Symbole der Apps, die im Hintergrund laufen (ohne Dock-Symbol oder ohne offenes Fenster).
# Klick auf ein Symbol öffnet/aktiviert die App. Baut die Bubble nur neu, wenn sich die Liste ändert.
SB=/opt/homebrew/bin/sketchybar
CACHE=/tmp/sketchybar-tray-list

LIST="$("$CONFIG_DIR/helpers/bg_apps")"
[ -f "$CACHE" ] && [ "$LIST" = "$(cat "$CACHE")" ] && $SB --query tray.app.gap >/dev/null 2>&1 && exit 0
echo "$LIST" > "$CACHE"

$SB --remove '/tray\.app\..*/' >/dev/null 2>&1 --remove tray >/dev/null 2>&1

[ -z "$LIST" ] && exit 0

# Abstand zur Nachbar-Bubble
$SB --add item tray.app.gap right --set tray.app.gap width=6 icon.drawing=off label.drawing=off >/dev/null
ITEMS=()
i=0
while IFS=$'\t' read -r id name; do
  [ -z "$id" ] && continue
  $SB --add item tray.app.$i right \
      --set tray.app.$i label.drawing=off icon.drawing=on icon="" \
                        icon.background.image="app.$id" icon.background.image.scale=0.6 \
                        icon.background.drawing=on \
                        icon.padding_left=0 icon.padding_right=0 \
                        padding_left=4 padding_right=4 \
                        click_script="open -b '$id'" >/dev/null
  ITEMS+=(tray.app.$i)
  i=$((i + 1))
done <<< "$LIST"

# etwas mehr Luft am Bubble-Rand
$SB --set "${ITEMS[0]}" padding_right=8 --set "${ITEMS[$((${#ITEMS[@]}-1))]}" padding_left=8 >/dev/null

source "$CONFIG_DIR/colors.sh"
$SB --add bracket tray "${ITEMS[@]}" \
    --set tray background.color=$BG1 background.corner_radius=9 background.height=28 \
               background.border_color=0xff504945 background.border_width=1 background.drawing=on >/dev/null
