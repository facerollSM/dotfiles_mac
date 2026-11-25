#!/bin/bash
# rofi/drun-artiger App-Launcher mit choose (brew install choose-gui), Gruvbox-Farben.
# Aufruf über Rift: physisch ⌥ + Leertaste.
# Liste nach Nutzung sortiert: oft gestartete Apps oben, dann gerade laufende, dann der Rest alphabetisch.
# Nochmal ⌥+Leertaste schließt ihn.
# Zusatz: Eingabe mit ">" am Anfang startet einen Shell-Befehl (wie rofi -show run), z. B. ">open ~/Downloads".
CHOOSE="${CHOOSE:-/opt/homebrew/bin/choose}"

# Zweites ⌥+Leertaste schließt den offenen Launcher wieder
if pgrep -x choose >/dev/null; then pkill -x choose; exit 0; fi

USAGE="$HOME/.local/state/launcher/usage"     # eine Zeile pro Start (letzte 500)
mkdir -p "$(dirname "$USAGE")"; touch "$USAGE"
TMP="$(mktemp -d -t launcher)"
trap 'rm -r "$TMP"' EXIT

# Alle Apps (versteckte wie ".Karabiner-…" auslassen)
{ find /Applications /Applications/Utilities /System/Applications /System/Applications/Utilities \
       "$HOME/Applications" -maxdepth 1 -name '*.app' ! -name '.*' 2>/dev/null
  echo /System/Library/CoreServices/Finder.app; } \
  | sed -E 's|.*/||; s|\.app$||' | sort -fu > "$TMP/all"

# Gerade laufende Apps (aus der Prozessliste, ohne Zusatz-Berechtigung)
ps -axo comm= | grep -oE '/[^/]+\.app/Contents/MacOS/' | sed -E 's|^/||; s|\.app/Contents/MacOS/$||' | sort -u > "$TMP/running"

# Rang: Nutzungszahl (+0.5 wenn läuft), dann alphabetisch
APPS="$(/usr/bin/python3 - "$TMP/all" "$TMP/running" "$USAGE" <<'PY'
import sys, collections
apps    = [l.rstrip("\n") for l in open(sys.argv[1]) if l.strip()]
running = {l.rstrip("\n") for l in open(sys.argv[2])}
usage   = collections.Counter(l.rstrip("\n") for l in open(sys.argv[3]) if l.strip())
apps.sort(key=lambda a: (-(usage[a] + (0.5 if a in running else 0)), a.lower()))
print("\n".join(apps))
PY
)"

SEL="$(echo "$APPS" | "$CHOOSE" -m -a -z -u -n 12 -w 30 -s 18 \
        -f "JetBrainsMono Nerd Font Mono" -c fabd2f -b 3c3836 -p "Starten …")"
[ -z "$SEL" ] && exit 0

if [[ "$SEL" == ">"* ]]; then
  /bin/zsh -lc "${SEL#>}" &>/dev/null &
elif open -a "$SEL" 2>/dev/null; then
  echo "$SEL" >> "$USAGE"
  tail -n 500 "$USAGE" > "$USAGE.tmp" && mv "$USAGE.tmp" "$USAGE"
else
  open "$SEL" 2>/dev/null
fi
