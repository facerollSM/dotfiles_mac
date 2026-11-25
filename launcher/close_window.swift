// Schließt das fokussierte Fenster der aktiven App (wie ein Klick auf den roten Knopf).
// Die App selbst läuft weiter – auch wenn es ihr letztes Fenster war.
import AppKit
import ApplicationServices
guard let app = NSWorkspace.shared.frontmostApplication else { exit(1) }
let ax = AXUIElementCreateApplication(app.processIdentifier)
var win: CFTypeRef?
guard AXUIElementCopyAttributeValue(ax, kAXFocusedWindowAttribute as CFString, &win) == .success,
      let window = win else { exit(1) }
var btn: CFTypeRef?
if AXUIElementCopyAttributeValue(window as! AXUIElement, kAXCloseButtonAttribute as CFString, &btn) == .success,
   let button = btn {
    AXUIElementPerformAction(button as! AXUIElement, kAXPressAction as CFString)
    exit(0)
}
exit(1)
