#!/bin/bash
# Maus verlässt Symbol + Popup → Popup schließen
if [ "$SENDER" = "mouse.exited.global" ]; then
  source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close volume; exit 0
fi
# Lautstärke anzeigen; über dem Symbol scrollen = lauter/leiser.

case "$SENDER" in
  mouse.scrolled)
    # Richtung bestimmen; Ereignisse ohne Bewegung (Delta 0, kommen beim Auslaufen) ignorieren –
    # die wurden früher als „leiser“ gewertet und sorgten für das Hoch/Runter-Springen.
    case "$SCROLL_DELTA" in
      ""|0|0.0|-0|-0.0) exit 0 ;;
      -*) DIR=-1 ;;
      *)  DIR=1 ;;
    esac

    # Richtungswechsel innerhalb von 0,6 s ignorieren (Trackpad federt am Ende kurz zurück)
    STATE=/tmp/sketchybar-volume-dir
    NOW=$(perl -MTime::HiRes=time -e 'printf "%d", time*1000')
    if [ -f "$STATE" ]; then
      read -r LASTDIR LASTT < "$STATE"
      if [ "$DIR" != "$LASTDIR" ] && [ $(( NOW - LASTT )) -lt 600 ]; then exit 0; fi
    fi
    echo "$DIR $NOW" > "$STATE"

    # Nur ein Schritt gleichzeitig: Trackpad-Wischen erzeugt viele Ereignisse auf einmal,
    # parallel laufende Skripte würden sich sonst gegenseitig überschreiben.
    LOCK=/tmp/sketchybar-volume.lock
    mkdir "$LOCK" 2>/dev/null || exit 0
    trap 'rmdir "$LOCK"' EXIT
    CUR="$(osascript -e 'output volume of (get volume settings)')"
    # Wie die Lautstärketasten: 16 Stufen à 6,25 %, immer auf einer Stufe einrasten
    NEW=$(/usr/bin/python3 -c "import math; s = math.floor($CUR / 6.25 + 0.5) + $DIR; print(math.floor(s * 6.25 + 0.5))")   # kaufmännisch runden wie macOS
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
