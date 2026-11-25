#!/bin/bash
# Kalender-Popup: Klick auf die Uhr zeigt den aktuellen Monat (Montag zuerst).
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/calendar_popup.sh"

fill() {
  local i=0
  popup_row clock today 󰃭 "$(LC_TIME=de_DE.UTF-8 date '+%A, %-d. %B %Y')" "" $YELLOW
  popup_row clock wd "" "  Mo Di Mi Do Fr Sa So" "" $GRAY
  # Wochenzeilen; die aktuelle Woche wird gelb hervorgehoben
  while IFS='|' read -r is_now line; do
    popup_row clock w$i "" "  $line" "" "$([ "$is_now" = 1 ] && echo $YELLOW || echo $FG)"
    i=$((i + 1))
  done < <(/usr/bin/python3 - <<'PY'
import calendar, datetime
t = datetime.date.today()
for week in calendar.Calendar(firstweekday=0).monthdayscalendar(t.year, t.month):
    row = " ".join(f"{d:2d}" if d else "  " for d in week)
    print(f"{int(t.day in week)}|{row}")
PY
)
  popup_row clock open 󰃭 "Kalender öffnen …" "$SELF close; open -a Calendar" $GRAY
}

case "$1" in
  close) popup_close clock ;;
  *)     popup_toggle clock fill ;;
esac
