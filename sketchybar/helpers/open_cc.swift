// Öffnet das Kontrollzentrum über das System-Kürzel Globe/fn + C.
// Simuliert vollständig: fn drücken → C drücken/loslassen → fn loslassen.
import CoreGraphics
import Foundation

let src = CGEventSource(stateID: .hidSystemState)
let fnKey: CGKeyCode = 63   // Globe/fn
let cKey: CGKeyCode = 8     // C

func post(_ key: CGKeyCode, down: Bool, flags: CGEventFlags) {
    let e = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: down)!
    e.flags = flags
    e.post(tap: .cghidEventTap)
    usleep(15_000)
}

// fn runter (flagsChanged)
let fnDown = CGEvent(keyboardEventSource: src, virtualKey: fnKey, keyDown: true)!
fnDown.type = .flagsChanged
fnDown.flags = .maskSecondaryFn
fnDown.post(tap: .cghidEventTap)
usleep(15_000)

post(cKey, down: true, flags: .maskSecondaryFn)
post(cKey, down: false, flags: .maskSecondaryFn)

// fn hoch (flagsChanged)
let fnUp = CGEvent(keyboardEventSource: src, virtualKey: fnKey, keyDown: false)!
fnUp.type = .flagsChanged
fnUp.flags = []
fnUp.post(tap: .cghidEventTap)
