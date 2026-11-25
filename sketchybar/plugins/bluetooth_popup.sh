#!/bin/bash
# Bluetooth-Popup: Bluetooth an/aus und gekoppelte Geräte verbinden/trennen.
# Aufrufe: bluetooth_popup.sh | close | power | toggle <adresse>
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/bluetooth_popup.sh"
BU=/opt/homebrew/bin/blueutil

fill() {
  if [ ! -x "$BU" ]; then
    popup_row bluetooth miss 󰀦 "blueutil fehlt: brew install blueutil" "" $ORANGE
    popup_row bluetooth set 󰒓 "Bluetooth-Einstellungen …" \
      "$SELF close; open 'x-apple.systempreferences:com.apple.BluetoothSettings'" $GRAY
    return
  fi

  if [ "$($BU -p)" = "1" ]; then
    popup_row bluetooth power 󰂯 "Bluetooth ausschalten" "$SELF power"
    local i=0
    while IFS=$'\t' read -r addr connected name; do
      [ -z "$addr" ] && continue
      if [ "$connected" = "1" ]; then
        popup_row bluetooth d$i 󰂱 "$name" "$SELF toggle $addr" $YELLOW
      else
        popup_row bluetooth d$i 󰂳 "$name" "$SELF toggle $addr"
      fi
      i=$((i + 1))
    done < <($BU --paired --format json | /usr/bin/python3 -c '
import sys, json
for d in json.load(sys.stdin):
    name = (d.get("name") or d.get("address") or "").replace("\t", " ")
    print(f"{d.get(\"address\")}\t{int(bool(d.get(\"connected\")))}\t{name}")
')
  else
    popup_row bluetooth power 󰂲 "Bluetooth einschalten" "$SELF power"
  fi

  popup_row bluetooth set 󰒓 "Bluetooth-Einstellungen …" \
    "$SELF close; open 'x-apple.systempreferences:com.apple.BluetoothSettings'" $GRAY
}

case "$1" in
  close) popup_close bluetooth ;;
  power)
    if [ "$($BU -p)" = "1" ]; then $BU -p 0; else $BU -p 1; fi
    popup_close bluetooth
    $SB --trigger bluetooth_change
    ;;
  toggle)
    if [ "$($BU --is-connected "$2")" = "1" ]; then $BU --disconnect "$2"; else $BU --connect "$2"; fi
    popup_close bluetooth
    $SB --trigger bluetooth_change
    ;;
  *) popup_toggle bluetooth fill ;;
esac
