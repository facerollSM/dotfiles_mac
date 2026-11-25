#!/bin/bash
# WLAN-Popup: Klick aufs Symbol klappt eine Liste der Netze in Reichweite auf.
# Aufrufe:
#   wifi_popup.sh            → Popup umschalten (Klick aufs WLAN-Symbol)
#   wifi_popup.sh connect N  → mit Netz Nr. N aus der Liste verbinden
#   wifi_popup.sh power      → WLAN an/aus
#   wifi_popup.sh close      → Popup schließen
source "$CONFIG_DIR/colors.sh"
SB=/opt/homebrew/bin/sketchybar
LIST=/tmp/sketchybar-wifi-list
STATE=/tmp/sketchybar-wifi-popup-open
SELF="$CONFIG_DIR/plugins/wifi_popup.sh"
FONT="JetBrainsMono Nerd Font Mono"

close() {
  rm -f "$STATE"
  $SB --set wifi popup.drawing=off
  $SB --remove '/wifi\.p\..*/' >/dev/null 2>&1
}

add_row() {  # name icon label click [color]
  $SB --add item "$1" popup.wifi \
      --set "$1" icon="$2" label="$3" click_script="$4" \
                 icon.font="$FONT:Bold:14.0" label.font="$FONT:Bold:13.0" \
                 icon.color="${5:-$FG}" label.color="${5:-$FG}" \
                 icon.padding_left=10 label.padding_right=12 \
                 background.drawing=off
}

fill() {
  $SB --remove '/wifi\.p\..*/' >/dev/null 2>&1

  POWER="$(networksetup -getairportpower en0 | awk '{print $NF}')"
  if [ "$POWER" = "On" ]; then
    add_row wifi.p.power 󰖩 "WLAN ausschalten" "$SELF power"
  else
    add_row wifi.p.power 󰖪 "WLAN einschalten" "$SELF power"
    add_row wifi.p.settings 󰒓 "WLAN-Einstellungen …" \
      "$SELF close; open 'x-apple.systempreferences:com.apple.wifi-settings-extension'" $GRAY
    return
  fi

  add_row wifi.p.loading 󰑓 "Suche Netze …" "" $GRAY

  # Aktuelles Netz + Netze in Reichweite (system_profiler dauert ein paar Sekunden)
  SP="$(system_profiler SPAirPortDataType 2>/dev/null)"
  CURRENT="$(echo "$SP" | sed -n '/Current Network Information:/{n;p;}' | grep -E ':$' | head -1 | sed -E 's/^ +//; s/:$//')"
  OTHERS="$(echo "$SP" | sed -n '/Other Local Wi-Fi Networks:/,$p' \
            | grep -E '^ {12}[^ ].*:$' | sed -E 's/^ +//; s/:$//' | awk '!seen[$0]++')"

  $SB --remove wifi.p.loading
  : > "$LIST"
  i=0
  if [ -n "$CURRENT" ]; then
    echo "$CURRENT" >> "$LIST"
    add_row wifi.p.net.$i 󰄬 "$CURRENT" "$SELF close" $YELLOW
    i=$((i + 1))
  fi
  while IFS= read -r ssid; do
    [ -z "$ssid" ] || [ "$ssid" = "$CURRENT" ] && continue
    echo "$ssid" >> "$LIST"
    add_row wifi.p.net.$i 󰖩 "$ssid" "$SELF connect $i"
    i=$((i + 1))
    [ $i -ge 10 ] && break
  done <<< "$OTHERS"

  add_row wifi.p.settings 󰒓 "WLAN-Einstellungen …" \
    "$SELF close; open 'x-apple.systempreferences:com.apple.wifi-settings-extension'" $GRAY
}

case "$1" in
  connect)
    SSID="$(sed -n "$(( $2 + 1 ))p" "$LIST")"
    close
    # Nutzt das im Schlüsselbund gespeicherte Passwort; unbekannte Netze → Einstellungen öffnen
    if ! networksetup -setairportnetwork en0 "$SSID" 2>&1 | grep -q .; then
      $SB --trigger wifi_change
    else
      open 'x-apple.systempreferences:com.apple.wifi-settings-extension'
    fi
    ;;
  power)
    if [ "$(networksetup -getairportpower en0 | awk '{print $NF}')" = "On" ]; then
      networksetup -setairportpower en0 off
    else
      networksetup -setairportpower en0 on
    fi
    close
    $SB --trigger wifi_change
    ;;
  close)
    close
    ;;
  *)
    if [ -e "$STATE" ]; then
      close
    else
      touch "$STATE"
      $SB --set wifi popup.drawing=on
      fill &
    fi
    ;;
esac
