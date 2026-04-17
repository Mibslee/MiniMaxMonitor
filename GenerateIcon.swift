#!/usr/bin/env swift
import AppKit
import Foundation

// macOS app icon sizes needed
let sizes: [(Int, String)] = [
    (16,   "AppIcon-16"),
    (32,   "AppIcon-32"),
    (64,   "AppIcon-64"),
    (128,  "AppIcon-128"),
    (256,  "AppIcon-256"),
    (512,  "AppIcon-512"),
    (1024, "AppIcon-1024"),
]

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    // ── Background ──────────────────────────────────────────────
    // Deep dark blue-black gradient
    let bgColors = [
        CGColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1),
        CGColor(red: 0.08, green: 0.13, blue: 0.20, alpha: 1),
    ]
    let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: bgColors as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(bgGradient,
        start: CGPoint(x: 0, y: s),
        end: CGPoint(x: s, y: 0),
        options: [])

    // ── Pill shape ───────────────────────────────────────────────
    let pillW  = s * 0.72
    let pillH  = s * 0.20
    let pillX  = (s - pillW) / 2
    let pillY  = (s - pillH) / 2
    let corner = pillH / 2

    let green = NSColor(red: 0.13, green: 0.74, blue: 0.35, alpha: 1.0)

    // Background of pill (faint)
    let pillRect = CGRect(x: pillX, y: pillY, width: pillW, height: pillH)
    let pillPath = CGPath(roundedRect: pillRect, cornerWidth: corner, cornerHeight: corner, transform: nil)

    ctx.saveGState()
    ctx.addPath(pillPath)
    ctx.setFillColor(green.withAlphaComponent(0.18).cgColor)
    ctx.fillPath()

    // Progress fill — 80% for a nice demo look
    let fillW = pillW * 0.80
    let fillRect = CGRect(x: pillX, y: pillY, width: fillW, height: pillH)
    ctx.addPath(pillPath)           // clip to pill
    ctx.clip()
    ctx.setFillColor(green.withAlphaComponent(0.82).cgColor)
    ctx.fill(fillRect)
    ctx.restoreGState()

    // Border
    ctx.addPath(pillPath)
    ctx.setStrokeColor(green.withAlphaComponent(0.6).cgColor)
    ctx.setLineWidth(max(1, s * 0.004))
    ctx.strokePath()

    // ── "token" text inside pill ─────────────────────────────────
    let tokenFontSize = s * 0.095
    let tokenFont = NSFont.systemFont(ofSize: tokenFontSize, weight: .bold)
    let tokenAttrs: [NSAttributedString.Key: Any] = [
        .font: tokenFont,
        .foregroundColor: NSColor.white.withAlphaComponent(0.95),
    ]
    let tokenStr = NSAttributedString(string: "token", attributes: tokenAttrs)
    let tokenSz  = tokenStr.size()
    tokenStr.draw(at: NSPoint(
        x: s / 2 - tokenSz.width / 2,
        y: s / 2 - tokenSz.height / 2
    ))

    // ── "MiniMax" label above pill ───────────────────────────────
    let labelFontSize = s * 0.055
    let labelFont = NSFont.systemFont(ofSize: labelFontSize, weight: .medium)
    let labelAttrs: [NSAttributedString.Key: Any] = [
        .font: labelFont,
        .foregroundColor: NSColor.white.withAlphaComponent(0.55),
    ]
    let labelStr = NSAttributedString(string: "MiniMax", attributes: labelAttrs)
    let labelSz  = labelStr.size()
    labelStr.draw(at: NSPoint(
        x: s / 2 - labelSz.width / 2,
        y: pillY + pillH + s * 0.045
    ))

    // ── "Monitor" label below pill ───────────────────────────────
    let subFont = NSFont.systemFont(ofSize: labelFontSize * 0.75, weight: .regular)
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: subFont,
        .foregroundColor: NSColor.white.withAlphaComponent(0.30),
    ]
    let subStr = NSAttributedString(string: "Monitor", attributes: subAttrs)
    let subSz  = subStr.size()
    subStr.draw(at: NSPoint(
        x: s / 2 - subSz.width / 2,
        y: pillY - s * 0.075
    ))

    // ── Subtle glow behind pill ──────────────────────────────────
    // (drawn before pill, but we'll add a soft overlay glow on top)
    let glowColors = [
        CGColor(red: 0.13, green: 0.74, blue: 0.35, alpha: 0.15),
        CGColor(red: 0.13, green: 0.74, blue: 0.35, alpha: 0.00),
    ]
    let glowGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: glowColors as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        glowGradient,
        startCenter: CGPoint(x: s / 2, y: s / 2),
        startRadius: 0,
        endCenter:   CGPoint(x: s / 2, y: s / 2),
        endRadius:   s * 0.42,
        options: []
    )

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to encode \(path)")
        return
    }
    do {
        try png.write(to: URL(fileURLWithPath: path))
        print("✓ \(path)")
    } catch {
        print("Error writing \(path): \(error)")
    }
}

// Output directory = AppIcon.appiconset in current working directory
let outDir = FileManager.default.currentDirectoryPath + "/AppIcon.appiconset"

for (size, name) in sizes {
    let img  = drawIcon(size: size)
    let path = "\(outDir)/\(name).png"
    savePNG(img, to: path)
}

print("\nAll icons written to \(outDir)")
