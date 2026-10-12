// 絵文字を描いた PNG を、iconutil が読む .iconset の形で書き出す。
// usage: makeicon EMOJI DIR
import AppKit

let args = CommandLine.arguments
guard args.count == 3 else {
  fputs("usage: makeicon EMOJI DIR\n", stderr)
  exit(2)
}
let emoji = args[1] as NSString
let dir = URL(fileURLWithPath: args[2])
try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

for base in [16, 32, 128, 256, 512] {
  for scale in [1, 2] {
    let px = base * scale
    guard
      let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0)
    else { exit(1) }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: CGFloat(px) * 0.8)
    ]
    let size = emoji.size(withAttributes: attributes)
    emoji.draw(
      at: NSPoint(x: (CGFloat(px) - size.width) / 2, y: (CGFloat(px) - size.height) / 2),
      withAttributes: attributes)
    NSGraphicsContext.restoreGraphicsState()
    guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
    let name = scale == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
    try png.write(to: dir.appendingPathComponent(name))
  }
}
