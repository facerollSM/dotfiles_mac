#!/bin/bash
# Akku-Popup: Klick aufs Akku-Symbol zeigt Details.
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/battery_popup.sh"

fill() {
  local B P STATUS REMAIN SRC WATTS IO CYCLES DESIGN MAX HEALTH
  B="$(pmset -g batt)"
  P="$(echo "$B" | grep -Eo '[0-9]+%' | head -1)"
  STATUS="$(echo "$B" | grep -Eo '%; [a-zA-Z ]+;' | sed -E 's/%; //; s/;//')"
  REMAIN="$(echo "$B" | grep -Eo '[0-9]+:[0-9]+ remaining' | awk '{print $1}')"
  IO="$(ioreg -rn AppleSmartBattery -w0)"
  CYCLES="$(echo "$IO" | grep -oE '"CycleCount" = [0-9]+' | head -1 | awk '{print $NF}')"
  DESIGN="$(echo "$IO" | grep -oE 'DesignCapacity"=[1-9][0-9]*' | head -1 | cut -d= -f2)"
  MAX="$(echo "$IO" | grep -oE 'AppleRawMaxCapacity"=[0-9]+' | head -1 | cut -d= -f2)"
  WATTS="$(echo "$IO" | grep -oE '"Watts"=[0-9]+' | head -1 | cut -d= -f2)"
  [ -n "$DESIGN" ] && [ -n "$MAX" ] && HEALTH="$(( MAX * 100 / DESIGN )) %"

  case "$STATUS" in
    charging)    STATUS="lädt" ;;
    discharging) STATUS="entlädt" ;;
    charged)     STATUS="voll geladen" ;;
    "finishing charge") STATUS="lädt fertig" ;;
    "AC attached") STATUS="Netzteil, lädt nicht" ;;
  esac

  popup_row battery head 󰁹 "$P · $STATUS" "" $YELLOW
  if echo "$B" | grep -q 'AC Power'; then
    popup_row battery src 󰚥 "Netzteil${WATTS:+ · ${WATTS} W}"
  else
    if [ -n "$REMAIN" ] && [ "$REMAIN" != "0:00" ]; then
      popup_row battery src 󰔟 "Akku · noch ${REMAIN} h"
    else
      popup_row battery src 󰔟 "Akku · Restzeit wird berechnet"
    fi
  fi
  [ -n "$CYCLES" ] && popup_row battery cyc 󰑓 "Ladezyklen: $CYCLES"
  [ -n "$HEALTH" ] && popup_row battery hl 󰓅 "Zustand: $HEALTH der Originalkapazität"
  popup_row battery set 󰒓 "Batterie-Einstellungen …" \
    "$SELF close; open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'" $GRAY
}

case "$1" in
  close) popup_close battery ;;
  *)     popup_toggle battery fill ;;
esac
