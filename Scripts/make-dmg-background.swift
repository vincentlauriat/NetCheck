#!/usr/bin/env swift
import AppKit

let size = CGSize(width: 540, height: 380)
let image = NSImage(size: size)
image.lockFocus()

let gradient = NSGradient(colors: [
    NSColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1),
    NSColor(red: 0.08, green: 0.08, blue: 0.18, alpha: 1)
])!
gradient.draw(in: NSRect(origin: .zero, size: size), angle: -45)

let para = NSMutableParagraphStyle()
para.alignment = .center
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 48),
    .paragraphStyle: para
]
"🌐".draw(in: NSRect(x: 60, y: 130, width: 90, height: 80), withAttributes: attrs)

let arrowAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 32, weight: .light),
    .foregroundColor: NSColor.white.withAlphaComponent(0.4),
    .paragraphStyle: para
]
"→".draw(in: NSRect(x: 220, y: 140, width: 100, height: 60), withAttributes: arrowAttrs)

"📁".draw(in: NSRect(x: 390, y: 130, width: 90, height: 80), withAttributes: attrs)

image.unlockFocus()

let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/background.png"
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: path))
print("✅ DMG background → \(path)")
