#!/bin/bash
# Power-Menü: Sperren, Ruhezustand, Abmelden, Neustart, Ausschalten.
# Abmelden/Neustart/Ausschalten zeigen die normale macOS-Rückfrage.
# Aufrufe: power_popup.sh | close | lock | sleep | logout | restart | shutdown
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/power_popup.sh"

fill() {
  popup_row power lock     󰌾 "Sperren"      "$SELF lock"
  popup_row power sleep    󰒲 "Ruhezustand"  "$SELF sleep"
  popup_row power logout   󰍃 "Abmelden …"   "$SELF logout"
  popup_row power restart  󰜉 "Neustart …"   "$SELF restart"   $YELLOW
  popup_row power shutdown 󰐥 "Ausschalten …" "$SELF shutdown" $RED
}

# Befehl an das Anmeldefenster (zeigt die übliche Bestätigung)
loginwindow() { osascript -e "tell application \"loginwindow\" to «event $1»"; }

case "$1" in
  close)    popup_close power ;;
  lock)     popup_close power; pmset displaysleepnow ;;
  sleep)    popup_close power; pmset sleepnow ;;
  logout)   popup_close power; loginwindow aevtlogo ;;
  restart)  popup_close power; loginwindow aevtrrst ;;
  shutdown) popup_close power; loginwindow aevtrsdn ;;
  *)        popup_toggle power fill ;;
esac
