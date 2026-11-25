// gruvboxify – recolors an image to the Gruvbox (dark) palette.
// Usage: gruvboxify <input> <output.png> [strength 0…1, default 0.85] [darken 0…1, default 0.15] [saturation boost, default 1.6]
// Each pixel takes the hue of a blend of its two nearest palette colors, but keeps its own
// brightness (smooth skies, no banding). Then it's mixed with the original (strength) and darkened.
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: gruvboxify <in> <out.png> [strength]"); exit(1) }
let strength = args.count > 3 ? Double(args[3]) ?? 0.85 : 0.85
let darken = args.count > 4 ? Double(args[4]) ?? 0.15 : 0.15
let sat = args.count > 5 ? Double(args[5]) ?? 1.6 : 1.6

let hex: [UInt32] = [
    0x1d2021, 0x282828, 0x32302f, 0x3c3836, 0x504945, 0x665c54, 0x7c6f64,   // backgrounds
    0x928374, 0xa89984, 0xbdae93, 0xd5c4a1, 0xebdbb2, 0xfbf1c7,             // gray → foreground
    0xcc241d, 0xfb4934, 0x98971a, 0xb8bb26, 0xd79921, 0xfabd2f,             // red, green, yellow
    0x458588, 0x83a598, 0xb16286, 0xd3869b, 0x689d6a, 0x8ec07c,             // blue, purple, aqua
    0xd65d0e, 0xfe8019,                                                     // orange
]
let pal: [(Double, Double, Double)] = hex.map {
    (Double(($0 >> 16) & 0xff), Double(($0 >> 8) & 0xff), Double($0 & 0xff))
}

guard let src = NSImage(contentsOfFile: args[1]),
      let cg = src.cgImage(forProposedRect: nil, context: nil, hints: nil) else { print("cannot read input"); exit(1) }
let w = cg.width, h = cg.height
var px = [UInt8](repeating: 0, count: w * h * 4)
let cs = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

// weighted color distance ("redmean"): perceptually decent and fast
@inline(__always) func dist(_ r: Double, _ g: Double, _ b: Double, _ p: (Double, Double, Double)) -> Double {
    let rm = (r + p.0) / 2, dr = r - p.0, dg = g - p.1, db = b - p.2
    return (2 + rm / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rm) / 256) * db * db
}

for i in stride(from: 0, to: px.count, by: 4) {
    var r = Double(px[i]), g = Double(px[i + 1]), b = Double(px[i + 2])
    // boost saturation first, so muted photo colors land on Gruvbox accents instead of grays
    let gray = 0.299 * r + 0.587 * g + 0.114 * b
    r = max(0, min(255, gray + (r - gray) * sat))
    g = max(0, min(255, gray + (g - gray) * sat))
    b = max(0, min(255, gray + (b - gray) * sat))
    var d1 = Double.greatestFiniteMagnitude, d2 = d1, i1 = 0, i2 = 0
    for (k, p) in pal.enumerated() {
        let d = dist(r, g, b, p)
        if d < d1 { d2 = d1; i2 = i1; d1 = d; i1 = k } else if d < d2 { d2 = d; i2 = k }
    }
    // inverse-distance blend of the two best matches
    let w1 = 1 / (sqrt(d1) + 1e-6), w2 = 1 / (sqrt(d2) + 1e-6), s = w1 + w2
    let p1 = pal[i1], p2 = pal[i2]
    var mr = (p1.0 * w1 + p2.0 * w2) / s, mg = (p1.1 * w1 + p2.1 * w2) / s, mb = (p1.2 * w1 + p2.2 * w2) / s
    // keep original brightness: scale palette color to the pixel's luminance
    let lo = 0.2126 * r + 0.7152 * g + 0.0722 * b
    let lm = max(1, 0.2126 * mr + 0.7152 * mg + 0.0722 * mb)
    let k = lo / lm
    mr *= k; mg *= k; mb *= k
    let f = 1 - darken
    px[i]     = UInt8(max(0, min(255, (mr * strength + r * (1 - strength)) * f)))
    px[i + 1] = UInt8(max(0, min(255, (mg * strength + g * (1 - strength)) * f)))
    px[i + 2] = UInt8(max(0, min(255, (mb * strength + b * (1 - strength)) * f)))
}

let out = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: out)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("ok \(w)x\(h) → \(args[2])")
