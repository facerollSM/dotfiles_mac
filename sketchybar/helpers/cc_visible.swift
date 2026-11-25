// Exit 0, wenn gerade ein Kontrollzentrum-Fenster (größer als ein Menüleisten-Symbol) sichtbar ist, sonst 1.
import CoreGraphics
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
for w in list {
    guard let owner = w[kCGWindowOwnerName as String] as? String,
          ["Control Center", "Control Centre", "Kontrollzentrum"].contains(owner),
          let b = w[kCGWindowBounds as String] as? [String: CGFloat],
          (b["Height"] ?? 0) > 100 else { continue }
    exit(0)
}
exit(1)
