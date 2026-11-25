// Schließt das fokussierte Fenster der aktiven App (wie ein Klick auf den roten Knopf).
// War es das letzte Fenster, wird die App beendet – außer sie steht in `keepRunning`.
import AppKit
import ApplicationServices

// Apps, die beim Schließen des letzten Fensters weiterlaufen sollen
let keepRunning: Set<String> = [
    "com.apple.Safari",
    "com.apple.finder",
]

guard let app = NSWorkspace.shared.frontmostApplication else { exit(1) }
let ax = AXUIElementCreateApplication(app.processIdentifier)

func windows() -> [AXUIElement] {
    var v: CFTypeRef?
    guard AXUIElementCopyAttributeValue(ax, kAXWindowsAttribute as CFString, &v) == .success,
          let list = v as? [AXUIElement] else { return [] }
    // nur normale Fenster zählen
    return list.filter { w in
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(w, kAXSubroleAttribute as CFString, &role)
        return (role as? String) == kAXStandardWindowSubrole as String
    }
}

var win: CFTypeRef?
guard AXUIElementCopyAttributeValue(ax, kAXFocusedWindowAttribute as CFString, &win) == .success,
      let window = win else { exit(1) }
var btn: CFTypeRef?
guard AXUIElementCopyAttributeValue(window as! AXUIElement, kAXCloseButtonAttribute as CFString, &btn) == .success,
      let button = btn else { exit(1) }
AXUIElementPerformAction(button as! AXUIElement, kAXPressAction as CFString)

if let id = app.bundleIdentifier, keepRunning.contains(id) { exit(0) }

// Kurz warten; bleibt kein Fenster übrig (z. B. kein „Änderungen sichern?“-Dialog), App beenden
usleep(300_000)
if windows().isEmpty { app.terminate() }
exit(0)
