// rec active → exit 0, wenn eine macOS-Bildschirmaufnahme läuft (Statussymbol von screencaptureui)
// rec stop   → beendet die Aufnahme (⌘ + Strg + Esc)
import CoreGraphics
import Foundation
let cmd = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "active"
if cmd == "stop" {
    let src = CGEventSource(stateID: .hidSystemState)
    for down in [true, false] {
        let e = CGEvent(keyboardEventSource: src, virtualKey: 53, keyDown: down)!
        e.flags = [.maskCommand, .maskControl]
        e.post(tap: .cghidEventTap)
        usleep(15_000)
    }
    exit(0)
}
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
for w in list {
    guard (w[kCGWindowOwnerName as String] as? String) == "screencaptureui",
          let layer = w[kCGWindowLayer as String] as? Int, layer >= 20,
          let b = w[kCGWindowBounds as String] as? [String: CGFloat],
          (b["Height"] ?? 999) < 60 else { continue }
    exit(0)
}
exit(1)
