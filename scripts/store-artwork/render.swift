#!/usr/bin/env swift
// Deterministic App Store artwork. Uses only Apple frameworks; captured UI is never redrawn.
import AppKit
import ImageIO
import UniformTypeIdentifiers

struct NativeDetail: Decodable {
    let label: String
    let image: String
    let crop: [Int]
}
struct Panel: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let image: String
    let footnote: String?
    /// Optional source-pixel crop; excludes only captured chrome outside the pictured content.
    let crop: [Int]?
    let variants: [NativeDetail]?
}
struct Artwork: Decodable {
    let appName: String
    let platform: String
    let width: Int
    let height: Int
    let background: String
    let foreground: String
    let roundedType: Bool?
    let output: String
    let panels: [Panel]
}
enum RenderFailure: Error { case message(String) }
func require(_ value: Bool, _ message: String) throws {
    if !value { throw RenderFailure.message(message) }
}
func color(_ hex: String) throws -> NSColor {
    let stripped = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard stripped.count == 6, let value = UInt32(stripped, radix: 16) else {
        throw RenderFailure.message("Invalid sRGB color: \(hex)")
    }
    return NSColor(srgbRed: CGFloat((value >> 16) & 255) / 255,
                   green: CGFloat((value >> 8) & 255) / 255,
                   blue: CGFloat(value & 255) / 255, alpha: 1)
}
func font(_ size: CGFloat, _ weight: NSFont.Weight, rounded: Bool) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    guard rounded, let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
    return NSFont(descriptor: descriptor, size: size) ?? base
}
func loadImage(_ url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw RenderFailure.message("Cannot read screenshot: \(url.path)")
    }
    return image
}
func drawText(_ text: String, rect: CGRect, font: NSFont, color: NSColor,
              canvasHeight: CGFloat, maximumLines: Int) throws {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = font.pointSize * 0.035
    let value = NSAttributedString(string: text, attributes: [
        .font: font, .foregroundColor: color, .paragraphStyle: paragraph,
        .kern: font.pointSize > 70 ? -font.pointSize * 0.025 : 0
    ])
    let bounds = value.boundingRect(with: NSSize(width: rect.width, height: .greatestFiniteMagnitude),
                                   options: [.usesLineFragmentOrigin, .usesFontLeading])
    try require(bounds.height <= rect.height + 1, "Text overflows reserved area: \(text)")
    try require(bounds.height <= font.pointSize * 1.35 * CGFloat(maximumLines), "Too many text lines: \(text)")
    value.draw(with: CGRect(x: rect.minX, y: canvasHeight - rect.minY - bounds.height,
                           width: rect.width, height: ceil(bounds.height)),
               options: [.usesLineFragmentOrigin, .usesFontLeading])
}
func drawDevice(_ image: CGImage, in area: CGRect, platform: String, height: CGFloat, context: CGContext) {
    let bezel: CGFloat = platform == "iphone" ? 13 : platform == "ipad" ? 20 : 0
    let scale = min(platform == "mac" ? 1 : .greatestFiniteMagnitude,
                    (area.width - bezel * 2) / CGFloat(image.width),
                    (area.height - bezel * 2) / CGFloat(image.height))
    let imageWidth = CGFloat(image.width) * scale
    let imageHeight = CGFloat(image.height) * scale
    let centeredX = area.midX - imageWidth / 2
    let centeredTop = area.minY + (area.height - imageHeight - bezel * 2) / 2
    // Native Mac crops at 1:1 land on whole canvas pixels to keep text crisp.
    let x = platform == "mac" ? centeredX.rounded() : centeredX
    let top = platform == "mac" ? centeredTop.rounded() : centeredTop
    let outer = CGRect(x: x - bezel, y: height - top - imageHeight - bezel * 2,
                       width: imageWidth + bezel * 2, height: imageHeight + bezel * 2)
    let radius: CGFloat = platform == "iphone" ? imageWidth * 0.13 : platform == "ipad" ? imageWidth * 0.038 : 24
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -14), blur: 34,
                      color: NSColor.black.withAlphaComponent(0.22).cgColor)
    context.setFillColor(NSColor(srgbRed: 0.075, green: 0.075, blue: 0.08, alpha: 1).cgColor)
    context.addPath(CGPath(roundedRect: outer, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.fillPath()
    context.restoreGState()
    if bezel > 0 {
        context.saveGState()
        context.setStrokeColor(NSColor.white.withAlphaComponent(0.32).cgColor)
        context.setLineWidth(2)
        context.addPath(CGPath(roundedRect: outer.insetBy(dx: 1, dy: 1), cornerWidth: radius,
                              cornerHeight: radius, transform: nil))
        context.strokePath()
        context.restoreGState()
    }
    let imageRect = CGRect(x: x, y: outer.minY + bezel, width: imageWidth, height: imageHeight)
    context.saveGState()
    let innerRadius = max(0, radius - bezel)
    context.addPath(CGPath(roundedRect: imageRect, cornerWidth: innerRadius,
                          cornerHeight: innerRadius, transform: nil))
    context.clip()
    context.interpolationQuality = .high
    context.draw(image, in: imageRect)
    context.restoreGState()
}

try require(CommandLine.arguments.count == 2, "Usage: swift render.swift /path/to/artwork.json")
let configURL = URL(fileURLWithPath: CommandLine.arguments[1]).standardizedFileURL
let root = configURL.deletingLastPathComponent()
let config = try JSONDecoder().decode(Artwork.self, from: Data(contentsOf: configURL))
try require(["iphone", "ipad", "mac"].contains(config.platform), "Unsupported platform")
let width = CGFloat(config.width), height = CGFloat(config.height)
let target = URL(fileURLWithPath: config.output, relativeTo: root).standardizedFileURL
try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
let background = try color(config.background), foreground = try color(config.foreground)
let mac = config.platform == "mac", pad = config.platform == "ipad"
let rounded = config.roundedType ?? true
let titleSize: CGFloat = mac ? 126 : pad ? 132 : 96
let subtitleSize: CGFloat = mac ? 48 : pad ? 58 : 43
let side: CGFloat = mac ? 150 : pad ? 145 : 90
let eyebrowY: CGFloat = mac ? 62 : pad ? 78 : 70
let titleY: CGFloat = mac ? 130 : pad ? 158 : 140
let titleHeight: CGFloat = mac ? 165 : pad ? 320 : 240
let subtitleY = titleY + titleHeight + (mac ? 0 : 18)
let subtitleHeight: CGFloat = mac ? 120 : pad ? 150 : 116
let deviceTop: CGFloat = mac ? 415 : pad ? 710 : 568

for panel in config.panels {
    try require(!panel.id.contains("/") && !panel.id.contains(".."), "Invalid panel ID")
    let sourceURL = URL(fileURLWithPath: panel.image, relativeTo: root).standardizedFileURL
    let original = try loadImage(sourceURL)
    let screenshot: CGImage
    if let crop = panel.crop {
        try require(crop.count == 4 && crop[0] >= 0 && crop[1] >= 0 && crop[2] > 0 && crop[3] > 0,
                    "Invalid source crop")
        try require(crop[0] + crop[2] <= original.width && crop[1] + crop[3] <= original.height,
                    "Crop exceeds native screenshot")
        guard let cropped = original.cropping(to: CGRect(x: crop[0], y: crop[1], width: crop[2], height: crop[3])) else {
            throw RenderFailure.message("Cannot crop native screenshot")
        }
        screenshot = cropped
    } else { screenshot = original }
    guard let space = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(data: nil, width: config.width, height: config.height,
              bitsPerComponent: 8, bytesPerRow: 0, space: space,
              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        throw RenderFailure.message("Cannot allocate opaque sRGB canvas")
    }
    context.setFillColor(background.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    try drawText(config.appName, rect: CGRect(x: side, y: eyebrowY, width: width - side * 2, height: 68),
                 font: font(mac ? 35 : pad ? 43 : 33, .semibold, rounded: rounded),
                 color: foreground.withAlphaComponent(0.86), canvasHeight: height, maximumLines: 1)
    try drawText(panel.title, rect: CGRect(x: side, y: titleY, width: width - side * 2, height: titleHeight),
                 font: font(titleSize, .heavy, rounded: rounded), color: foreground,
                 canvasHeight: height, maximumLines: mac ? 1 : 2)
    try drawText(panel.subtitle, rect: CGRect(x: side, y: subtitleY, width: width - side * 2, height: subtitleHeight),
                 font: font(subtitleSize, .medium, rounded: rounded), color: foreground,
                 canvasHeight: height, maximumLines: 2)
    let bottom: CGFloat = panel.footnote == nil ? (mac ? 80 : 88) : 155
    let available = CGRect(x: mac ? 130 : pad ? 210 : 115, y: deviceTop,
                           width: width - (mac ? 260 : pad ? 420 : 230), height: height - deviceTop - bottom)
    if let variants = panel.variants {
        try require(mac && variants.count == 4, "The native display-style grid requires four Mac captures")
        let gap: CGFloat = 50
        let cellWidth = (available.width - gap) / 2
        let cellHeight = (available.height - gap) / 2
        for (index, variant) in variants.enumerated() {
            let native = try loadImage(URL(fileURLWithPath: variant.image, relativeTo: root).standardizedFileURL)
            let crop = variant.crop
            try require(crop.count == 4 && crop[0] >= 0 && crop[1] >= 0 && crop[2] > 0 && crop[3] > 0
                        && crop[0] + crop[2] <= native.width && crop[1] + crop[3] <= native.height,
                        "Invalid native display-style crop")
            guard let detail = native.cropping(to: CGRect(x: crop[0], y: crop[1], width: crop[2], height: crop[3])) else {
                throw RenderFailure.message("Cannot crop display style")
            }
            let cell = CGRect(x: available.minX + CGFloat(index % 2) * (cellWidth + gap),
                              y: available.minY + CGFloat(index / 2) * (cellHeight + gap),
                              width: cellWidth, height: cellHeight)
            try drawText(variant.label, rect: CGRect(x: cell.minX, y: cell.minY, width: cell.width, height: 58),
                         font: font(40, .semibold, rounded: false), color: foreground,
                         canvasHeight: height, maximumLines: 1)
            drawDevice(detail, in: CGRect(x: cell.minX, y: cell.minY + 68, width: cell.width, height: cell.height - 68),
                       platform: "mac", height: height, context: context)
        }
    } else {
        drawDevice(screenshot, in: available, platform: config.platform, height: height, context: context)
    }
    if let footnote = panel.footnote {
        try drawText(footnote, rect: CGRect(x: side, y: height - 112, width: width - side * 2, height: 83),
                     font: font(mac ? 29 : pad ? 34 : 26, .medium, rounded: rounded),
                     color: foreground, canvasHeight: height, maximumLines: 2)
    }
    NSGraphicsContext.restoreGraphicsState()
    guard let image = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(target.appendingPathComponent(panel.id + ".png") as CFURL,
              UTType.png.identifier as CFString, 1, nil) else {
        throw RenderFailure.message("Cannot create PNG export")
    }
    CGImageDestinationAddImage(destination, image, [kCGImagePropertyPNGDictionary: [kCGImagePropertyPNGSoftware: "StoreArtwork 2026-10-12"]] as CFDictionary)
    try require(CGImageDestinationFinalize(destination), "PNG export failed")
    print("\(panel.id): \(config.width)×\(config.height), opaque sRGB, \(sourceURL.lastPathComponent)")
}
