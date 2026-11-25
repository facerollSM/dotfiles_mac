// Rechnet ein App-Symbol für die Tray um und speichert es als PNG.
// Aufruf: tray_icon <bundle-id> <stil> <ausgabe.png>
//   stil: gruvbox (einfarbig im Gruvbox-Vordergrundton) | gray (Graustufen) | color (unverändert)
import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count == 4,
      let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: args[1]) else { exit(1) }
let style = args[2], out = args[3]

// Symbol in genau 64×64 px zeichnen (feste Größe → feste Skalierung in der Leiste)
let px = 64
let icon = NSWorkspace.shared.icon(forFile: url.path)
guard let bmp = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                                 samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                 colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bmp)
icon.draw(in: NSRect(x: 0, y: 0, width: px, height: px))
NSGraphicsContext.restoreGraphicsState()
guard var image = CIImage(bitmapImageRep: bmp) else { exit(1) }

switch style {
case "gray":
    let f = CIFilter(name: "CIColorControls")!
    f.setValue(image, forKey: kCIInputImageKey)
    f.setValue(0.0, forKey: kCIInputSaturationKey)
    f.setValue(0.9, forKey: kCIInputContrastKey)
    image = f.outputImage!
case "gruvbox":
    // erst entsättigen, dann im Gruvbox-Vordergrundton (#ebdbb2) einfärben
    let g = CIFilter(name: "CIColorControls")!
    g.setValue(image, forKey: kCIInputImageKey)
    g.setValue(0.0, forKey: kCIInputSaturationKey)
    let m = CIFilter(name: "CIColorMonochrome")!
    m.setValue(g.outputImage!, forKey: kCIInputImageKey)
    m.setValue(CIColor(red: 0xeb / 255.0, green: 0xdb / 255.0, blue: 0xb2 / 255.0), forKey: kCIInputColorKey)
    m.setValue(1.0, forKey: kCIInputIntensityKey)
    image = m.outputImage!
default:
    break
}

let ctx = CIContext()
guard let cg = ctx.createCGImage(image, from: image.extent) else { exit(1) }
let rep = NSBitmapImageRep(cgImage: cg)
guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try? png.write(to: URL(fileURLWithPath: out))
