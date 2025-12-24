#!/bin/bash

echo "🎨 Creating App Icon for Bulk Renaming Utility..."
echo ""

# Create a temporary directory for icon generation
mkdir -p AppIcon.iconset

# Generate PNG icons at different sizes using Swift
cat > generate_icon.swift << 'ICONCODE'
import Cocoa
import CoreGraphics

func createIcon(size: CGFloat, filename: String) {
    let imageSize = NSSize(width: size, height: size)
    let image = NSImage(size: imageSize)

    image.lockFocus()

    let rect = NSRect(origin: .zero, size: imageSize)

    // Apple-style gradient background (vibrant blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),      // Bright blue
        NSColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0)      // Deeper blue
    ])
    gradient?.draw(in: rect, angle: 135)

    // Main content area - centered composition
    let contentSize = size * 0.65
    let contentX = (size - contentSize) / 2
    let contentY = (size - contentSize) / 2

    // Draw stacked documents with ABC -> 123 transformation
    let docWidth = contentSize * 0.4
    let docHeight = contentSize * 0.55

    // Left document (ABC - representing original names)
    let leftDocRect = NSRect(x: contentX,
                            y: contentY + contentSize * 0.1,
                            width: docWidth,
                            height: docHeight)
    drawDocument(in: leftDocRect, baseColor: .white)

    // Draw "ABC" text on left document
    drawText("ABC", in: leftDocRect, color: NSColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), size: size * 0.11)

    // Right document (123 - representing renamed with numbers)
    let rightDocRect = NSRect(x: contentX + contentSize * 0.5,
                             y: contentY + contentSize * 0.1,
                             width: docWidth,
                             height: docHeight)
    drawDocument(in: rightDocRect, baseColor: .white)

    // Draw "123" text on right document
    drawText("123", in: rightDocRect, color: NSColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), size: size * 0.11)

    // Draw curved arrow from left to right (transformation indicator)
    let arrowPath = NSBezierPath()
    let arrowMidY = contentY + contentSize * 0.4
    let arrowStartX = contentX + docWidth
    let arrowEndX = contentX + contentSize * 0.5

    // Curved arrow using bezier curve
    arrowPath.move(to: NSPoint(x: arrowStartX + size * 0.03, y: arrowMidY))
    arrowPath.curve(to: NSPoint(x: arrowEndX - size * 0.03, y: arrowMidY),
                   controlPoint1: NSPoint(x: arrowStartX + size * 0.08, y: arrowMidY - size * 0.05),
                   controlPoint2: NSPoint(x: arrowEndX - size * 0.08, y: arrowMidY - size * 0.05))

    // Arrow styling
    arrowPath.lineWidth = size * 0.025
    arrowPath.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.95).setStroke()
    arrowPath.stroke()

    // Arrow head
    let headPath = NSBezierPath()
    let headSize = size * 0.06
    let headX = arrowEndX - size * 0.03

    headPath.move(to: NSPoint(x: headX, y: arrowMidY))
    headPath.line(to: NSPoint(x: headX - headSize, y: arrowMidY - headSize * 0.5))
    headPath.move(to: NSPoint(x: headX, y: arrowMidY))
    headPath.line(to: NSPoint(x: headX - headSize, y: arrowMidY + headSize * 0.5))

    headPath.lineWidth = size * 0.025
    headPath.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.95).setStroke()
    headPath.stroke()

    image.unlockFocus()

    // Save as PNG
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: filename))
    }
}

func drawDocument(in rect: NSRect, baseColor: NSColor) {
    // Modern document shape with rounded corners
    let cornerRadius = rect.width * 0.12
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Main document fill
    baseColor.setFill()
    path.fill()

    // Subtle shadow/border for depth
    NSColor.black.withAlphaComponent(0.1).setStroke()
    path.lineWidth = rect.width * 0.01
    path.stroke()

    // Add subtle lines to indicate text content
    let lineInset = rect.width * 0.2
    let lineSpacing = rect.height * 0.12
    let startY = rect.minY + rect.height * 0.3

    NSColor.black.withAlphaComponent(0.08).setStroke()

    for i in 0..<3 {
        let linePath = NSBezierPath()
        let y = startY + CGFloat(i) * lineSpacing
        linePath.move(to: NSPoint(x: rect.minX + lineInset, y: y))
        linePath.line(to: NSPoint(x: rect.maxX - lineInset, y: y))
        linePath.lineWidth = rect.width * 0.015
        linePath.lineCapStyle = .round
        linePath.stroke()
    }
}

func drawText(_ text: String, in rect: NSRect, color: NSColor, size: CGFloat) {
    let font = NSFont.boldSystemFont(ofSize: size)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle
    ]

    let nsText = text as NSString
    let textSize = nsText.size(withAttributes: attrs)
    let textRect = NSRect(x: rect.minX,
                         y: rect.midY - textSize.height / 2,
                         width: rect.width,
                         height: textSize.height)

    nsText.draw(in: textRect, withAttributes: attrs)
}

// Generate all required sizes
let sizes: [(size: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

for (size, scale) in sizes {
    let actualSize = size * scale
    let filename = scale == 1
        ? "AppIcon.iconset/icon_\(size)x\(size).png"
        : "AppIcon.iconset/icon_\(size)x\(size)@\(scale)x.png"
    createIcon(size: CGFloat(actualSize), filename: filename)
    print("✅ Generated: \(filename)")
}

print("\n🎨 All icon sizes generated!")
ICONCODE

echo "📦 Compiling icon generator..."
swiftc -framework Cocoa -o generate_icon generate_icon.swift

if [ $? -ne 0 ]; then
    echo "❌ Icon generator compilation failed!"
    exit 1
fi

echo "🎨 Generating icon files..."
./generate_icon

# Convert to .icns format
echo ""
echo "🔄 Converting to .icns format..."
iconutil -c icns AppIcon.iconset -o AppIcon.icns

if [ $? -ne 0 ]; then
    echo "❌ Icon conversion failed!"
    exit 1
fi

echo "✅ AppIcon.icns created!"
echo ""

# Copy the 512x512 version for use in the app UI
cp AppIcon.iconset/icon_512x512.png AppIcon512.png
echo "✅ AppIcon512.png created for UI display"

# Cleanup
rm -rf AppIcon.iconset generate_icon.swift generate_icon

echo ""
echo "✅ Icon Creation Complete!"
echo ""
echo "📁 Created files:"
echo "  - AppIcon.icns (for app bundle)"
echo "  - AppIcon512.png (for UI display)"
echo ""
