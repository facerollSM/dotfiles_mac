#!/bin/bash
# Holt die aktuellen Configs vom System ins Repo (danach: git diff / git commit).
set -e
cd "$(dirname "$0")"
C="$HOME/.config"
rsync -a --delete "$C/rift/config.toml" rift/
rsync -a --delete --exclude 'helpers/*' --include 'helpers/' "$C/sketchybar/" sketchybar/
mkdir -p sketchybar/helpers && rsync -a "$C/sketchybar/helpers/"*.swift sketchybar/helpers/
rsync -a --delete --exclude '*.bak' "$C/kitty/" kitty/
rsync -a "$C/borders/bordersrc" borders/
rsync -a "$C/launcher/" launcher/
rsync -a "$C/zsh/gruvbox.zsh" zsh/
rsync -a "$HOME/Library/Application Support/Code/User/keybindings.json" vscode/
/opt/homebrew/bin/brew bundle dump --force --file=Brewfile >/dev/null
# private/lokale Taps ohne öffentliche Quelle nicht ins Repo
sed -i '' "/^tap \"$USER\//d" Brewfile   # eigene lokale Taps (benannt nach Benutzer)

# Persönlichen Home-Pfad durch Platzhalter ersetzen (install.sh setzt ihn wieder ein)
grep -rlF "$HOME" --exclude-dir=.git --exclude=sync.sh --exclude=install.sh . 2>/dev/null \
  | while IFS= read -r f; do sed -i '' "s|$HOME|__HOME__|g" "$f"; done
echo "Synchronisiert. Änderungen ansehen mit: git -C $(pwd) status"
