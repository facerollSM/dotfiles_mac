#!/bin/bash
# Maus verlässt Symbol + Popup → Popup schließen
if [ "$SENDER" = "mouse.exited.global" ]; then
  source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close volume; exit 0
fi
# Lautstärke anzeigen; über dem Symbol scrollen = lauter/leiser.

case "$SENDER" in
  mouse.scrolled)
    # Nur ein Schritt gleichzeitig: Trackpad-Wischen erzeugt viele Ereignisse auf einmal,
    # parallel laufende Skripte würden sich sonst gegenseitig überschreiben (hoch/runter-Springen).
    LOCK=/tmp/sketchybar-volume.lock
    mkdir "$LOCK" 2>/dev/null || exit 0
    trap 'rmdir "$LOCK"' EXIT
    CUR="$(osascript -e 'output volume of (get volume settings)')"
    STEP=$(( SCROLL_DELTA > 0 ? 3 : -3 ))   # 3 % pro Scroll-Schritt
    NEW=$(( CUR + STEP ))
    (( NEW < 0 )) && NEW=0
    (( NEW > 100 )) && NEW=100
    osascript -e "set volume output volume $NEW"
    VOL=$NEW
    ;;
  volume_change)
    VOL="$INFO"
    ;;
  *)
    VOL="$(osascript -e 'output volume of (get volume settings)')"
    ;;
esac

case "$VOL" in
  [6-9][0-9]|100)   ICON="󰕾" ;;
  [3-5][0-9])       ICON="󰖀" ;;
  [1-9]|[1-2][0-9]) ICON="󰕿" ;;
  *)                ICON="󰖁" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
