#!/bin/bash
# Neues, leeres Safari-Fenster (statt zweiter Safari-Instanz mit wiederhergestellten Tabs).
# Läuft Safari nicht, wird es einfach gestartet.
if pgrep -xq Safari; then
  osascript -e 'tell application "Safari"
    make new document
    activate
  end tell'
else
  open -a Safari
fi
