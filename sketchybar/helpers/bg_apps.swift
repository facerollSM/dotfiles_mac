// Listet Apps, die im Hintergrund laufen: Menüleisten-Apps (ohne Dock-Symbol)
// und normale Apps ohne sichtbares Fenster (z. B. BTT, Telegram mit geschlossenem Fenster).
// Ausgabe: bundle-id<TAB>name — Apple-Apps und eingebettete Helfer werden ausgelassen.
import AppKit
// Nie in der Tray anzeigen
let skip: Set<String> = [
    "com.felixkratz.sketchybar",
    "net.kovidgoyal.kitty",
]

// PIDs mit normalem, sichtbarem Fenster (Ebene 0)
let wins = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
var withWindow = Set<pid_t>()
for w in wins where (w[kCGWindowLayer as String] as? Int) == 0 {
    if let b = w[kCGWindowBounds as String] as? [String: CGFloat], (b["Width"] ?? 0) > 50, (b["Height"] ?? 0) > 50,
       let pid = w[kCGWindowOwnerPID as String] as? pid_t { withWindow.insert(pid) }
}

var seen = Set<String>()
for app in NSWorkspace.shared.runningApplications where app.activationPolicy != .prohibited {
    guard let id = app.bundleIdentifier, !id.hasPrefix("com.apple."), !skip.contains(id),
          let url = app.bundleURL,
          // echtes App-Paket (auch ohne .app-Endung, z. B. Steam), aber nichts, was in einem anderen Paket steckt
          FileManager.default.fileExists(atPath: url.appendingPathComponent("Contents/Info.plist").path),
          !url.deletingLastPathComponent().path.contains("/Contents"),
          !seen.contains(id) else { continue }
    if app.activationPolicy == .regular && withWindow.contains(app.processIdentifier) { continue }
    seen.insert(id)
    print("\(id)\t\(app.localizedName ?? id)")
}
