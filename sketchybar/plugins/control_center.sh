#!/bin/bash
# Kontrollzentrum per Klick öffnen/schließen (über das System-Kürzel Globe/fn + C).
# Helfer (Quelltext in ../helpers/*.swift), neu bauen mit:
#   swiftc -O ~/.config/sketchybar/helpers/open_cc.swift   -o ~/.config/sketchybar/helpers/open_cc
#   swiftc -O ~/.config/sketchybar/helpers/cc_visible.swift -o ~/.config/sketchybar/helpers/cc_visible
H="$CONFIG_DIR/helpers"

# War es beim Klick offen? Dann hat der Klick es bereits geschlossen – nicht wieder öffnen.
"$H/cc_visible" && exit 0

# kurz warten, bis der Klick abgeschlossen ist – sonst schließt er das Kontrollzentrum gleich wieder
sleep 0.15
"$H/open_cc"
