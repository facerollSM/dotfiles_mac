# dotfiles – macOS mit Linux-Gefühl

| Ordner | Inhalt |
|---|---|
| `rift/` | Tiling-WM Rift im niri-Stil (Scrolling, 50 % Spalten, App-Regeln, Tastenkürzel) |
| `sketchybar/` | Bubble-Leiste (Gruvbox): Workspaces, Medien, Tray, Bluetooth, WLAN, Lautstärke, Akku, Kalender, Kontrollzentrum, REC; `helpers/*.swift` werden bei der Installation gebaut |
| `kitty/` | Terminal mit Linux-Strg-Belegung |
| `borders/` | Fensterrahmen (gelb = Fokus) |
| `launcher/` | rofi-artiger App-Launcher (choose), physisch ⌥+Leertaste |
| `macos/` | Tastentausch (Strg→⌘, ⌘→⌥, ⌥→Strg) und schnellere Animationen |
| `btt/` | Hinweise zu BetterTouchTool |
| `Brewfile` | alle Homebrew-Pakete |

## Benutzung
```bash
./sync.sh                 # System → Repo (danach committen)
./install.sh              # Repo → System
./install.sh --brew --macos   # neuer Mac: Pakete + macOS-Einstellungen dazu
```

Nach einer Neuinstallation für **sketchybar** in Datenschutz & Sicherheit freigeben:
Bedienungshilfen, Bildschirm- & Systemaudioaufnahme, Bluetooth.
