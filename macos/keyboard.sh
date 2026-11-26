#!/bin/bash
# Linux-Tastenbelegung auf der internen Tastatur: Strg→⌘, ⌘→⌥, ⌥→Strg (bleibt nach Neustart erhalten).
# Dazu: Spotlight/Eingabequellen-Kürzel auf dieselben physischen Tasten, alte Strg-Menükürzel entfernen.
L(){ printf '%d' "$1"; }
pair(){ echo "<dict><key>HIDKeyboardModifierMappingSrc</key><integer>$(L $1)</integer><key>HIDKeyboardModifierMappingDst</key><integer>$(L $2)</integer></dict>"; }
# Schlüssel hängt von Vendor-/Product-ID der internen Tastatur ab (Intel-MacBook z. B. 1452-835-0,
# Apple-Silicon-MacBooks melden 0-0-0). Selbst ermitteln; überschreibbar mit KEYBOARD_ID=1452-835-0.
if [ -z "$KEYBOARD_ID" ]; then
  read -r VID PID < <(hidutil list --matching '{"PrimaryUsagePage":1,"PrimaryUsage":6}' 2>/dev/null \
    | awk '/^Services:/{s=1;next} /^Devices:/{s=0} s && /Internal Keyboard/ {print $1, $2; exit}')
  [ -n "$VID" ] || { echo "FEHLER: interne Tastatur nicht gefunden – KEYBOARD_ID=<vendor>-<product>-0 setzen." >&2; exit 1; }
  KEYBOARD_ID="$(L "$VID")-$(L "$PID")-0"
fi
echo "Tastatur: $KEYBOARD_ID"
defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$KEYBOARD_ID" -array \
  "$(pair 0x7000000E0 0x7000000E3)" "$(pair 0x7000000E3 0x7000000E2)" "$(pair 0x7000000E2 0x7000000E0)" \
  "$(pair 0x7000000E4 0x7000000E7)" "$(pair 0x7000000E7 0x7000000E6)" "$(pair 0x7000000E6 0x7000000E4)"

hk(){ defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $1 "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>$2</integer></array></dict></dict>"; }
hk 64 393216    # Spotlight: physisch ⌥+Shift+Leertaste (⌥+Leertaste = Launcher über Rift)
hk 60 1048576   # Vorherige Eingabequelle: physisch Strg+Leertaste
hk 61 1310720   # Nächste Eingabequelle: physisch Strg+⌥+Leertaste
defaults delete -g NSUserKeyEquivalents 2>/dev/null || true
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
echo "Tastenbelegung gesetzt – bitte einmal ab- und wieder anmelden."
echo "Hinweis: Safari-App-Kürzel mit ⌃ in Systemeinstellungen → Tastatur → App-Tastaturkurzbefehle löschen."
