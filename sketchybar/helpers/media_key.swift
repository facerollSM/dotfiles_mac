// Sendet eine Medientaste: media_key play|next|prev
import AppKit
let keys: [String: Int] = ["play": 16, "next": 17, "prev": 18]
guard CommandLine.arguments.count > 1, let key = keys[CommandLine.arguments[1]] else {
    print("usage: media_key play|next|prev"); exit(1)
}
for down in [true, false] {
    let state = down ? 0xa : 0xb
    let ev = NSEvent.otherEvent(with: .systemDefined, location: .zero,
                                modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(state << 8)),
                                timestamp: 0, windowNumber: 0, context: nil, subtype: 8,
                                data1: (key << 16) | (state << 8), data2: -1)
    ev?.cgEvent?.post(tap: .cghidEventTap)
    usleep(10_000)
}
