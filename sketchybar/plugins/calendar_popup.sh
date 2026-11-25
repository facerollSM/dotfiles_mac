#!/bin/bash
# Kalender-Popup: Klick auf die Uhr zeigt den aktuellen Monat (Montag zuerst).
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/calendar_popup.sh"


fill() {
  local i=0
  popup_row clock today 󰃭 "$(LC_TIME=de_DE.UTF-8 date '+%A, %-d. %B %Y')" "" $YELLOW
  popup_row clock wd "" "Mo Di Mi Do Fr Sa So" "" $GRAY
  $SB --set clock.p.wd label.padding_left=32 >/dev/null
  # Wochenzeilen; die aktuelle Woche wird gelb hervorgehoben.
  # Leere Tage am Wochenanfang werden über den Einzug ausgeglichen (SketchyBar kürzt führende Leerzeichen).
  local CH=7.75   # Breite eines Zeichens in px (JetBrains Mono, 13 pt)
  while IFS='|' read -r is_now blanks line; do
    popup_row clock w$i "" "$line" "" "$([ "$is_now" = 1 ] && echo $YELLOW || echo $FG)"
    $SB --set clock.p.w$i label.padding_left=$(echo "32 + $blanks * $CH" | bc) >/dev/null
    i=$((i + 1))
  done < <(/usr/bin/python3 - <<'PY'
import calendar, datetime
t = datetime.date.today()
for week in calendar.Calendar(firstweekday=0).monthdayscalendar(t.year, t.month):
    blanks = 0
    while blanks < 7 and week[blanks] == 0:
        blanks += 1
    row = " ".join(f"{d:2d}" for d in week[blanks:] if d)
    lead = blanks * 3 + (len(row) - len(row.lstrip()))   # Zeichen, um die eingerückt werden muss
    print("%d|%d|%s" % (int(t.day in week), lead, row.lstrip()))
PY
)
  popup_row clock open 󰃭 "Kalender öffnen …" "$SELF close; open -a Calendar" $GRAY
}

case "$1" in
  close) popup_close clock ;;
  *)     popup_toggle clock fill ;;
esac
