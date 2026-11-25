#!/bin/bash
# Bringt die Configs aus dem Repo an ihren Platz (vorhandene Dateien werden nach *.bak-<Datum> gesichert).
#   ./install.sh            → nur Configs
#   ./install.sh --brew     → also install the core packages (Brewfile.core)
#   ./install.sh --brew-all → also install everything from the full Brewfile
#   ./install.sh --macos    → zusätzlich Tastentausch + Animations-Einstellungen anwenden
set -e
cd "$(dirname "$0")"
C="$HOME/.config"; STAMP="$(date +%Y%m%d-%H%M%S)"

backup() { [ -e "$1" ] && cp -Rp "$1" "$1.bak-$STAMP" && echo "  gesichert: $1.bak-$STAMP" || true; }

[[ " $* " == *" --brew "* ]]     && /opt/homebrew/bin/brew bundle --file=Brewfile.core
[[ " $* " == *" --brew-all "* ]] && /opt/homebrew/bin/brew bundle --file=Brewfile

echo "Configs kopieren …"
mkdir -p "$C"/{rift,sketchybar,kitty,borders,launcher}
backup "$C/rift/config.toml";      cp rift/config.toml "$C/rift/"
backup "$C/sketchybar";            rsync -a sketchybar/ "$C/sketchybar/"
backup "$C/kitty/kitty.conf";      rsync -a kitty/ "$C/kitty/"
backup "$C/borders/bordersrc";     cp borders/bordersrc "$C/borders/"
rsync -a launcher/ "$C/launcher/"
mkdir -p "$C/zsh" && cp zsh/gruvbox.zsh "$C/zsh/"
VSC="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSC"; backup "$VSC/keybindings.json"; cp vscode/keybindings.json "$VSC/"
grep -q 'config/zsh/gruvbox.zsh' "$HOME/.zshrc" 2>/dev/null || \
  echo '[[ -f ~/.config/zsh/gruvbox.zsh ]] && source ~/.config/zsh/gruvbox.zsh   # Gruvbox prompt + fzf colors' >> "$HOME/.zshrc"
# Platzhalter __HOME__ durch den echten Home-Pfad ersetzen
grep -rlF "__HOME__" "$C/rift" "$C/sketchybar" "$C/kitty" "$C/borders" "$C/launcher" 2>/dev/null \
  | while IFS= read -r f; do sed -i '' "s|__HOME__|$HOME|g" "$f"; done
chmod +x "$C"/sketchybar/sketchybarrc "$C"/sketchybar/plugins/*.sh "$C"/launcher/*.sh "$C"/borders/bordersrc

echo "SketchyBar-Helfer bauen …"
for s in "$C"/sketchybar/helpers/*.swift "$C"/launcher/*.swift; do swiftc -O "$s" -o "${s%.swift}"; done

[[ " $* " == *" --macos "* ]] && ./macos/keyboard.sh && ./macos/animations.sh

echo "Dienste neu starten …"
/opt/homebrew/bin/rift service install >/dev/null 2>&1 || true
/opt/homebrew/bin/rift service start   >/dev/null 2>&1 || true
/opt/homebrew/bin/brew services restart sketchybar >/dev/null || true
/opt/homebrew/bin/brew services restart borders   >/dev/null || true
/opt/homebrew/bin/rift-cli execute config reload  >/dev/null 2>&1 || true
echo "Fertig. Freigaben (Bedienungshilfen, Bildschirmaufnahme, Bluetooth für sketchybar) ggf. neu erteilen."
