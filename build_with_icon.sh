#!/bin/bash

echo "🎨 Building macOS GUI App with Custom Icon..."
echo ""

# Clean up
rm -rf BulkRenamer.app

# Build the app first using swiftc
echo "📦 Building executable..."
swiftc \
    -target arm64-apple-macosx26.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework SwiftUI \
    -framework AppKit \
    -framework UniformTypeIdentifiers \
    -o BulkRenamer \
    Sources/FileRenamer.swift \
    Sources/NamingPattern.swift \
    BulkRenamerApp.swift

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="BulkRenamer.app"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

# Move executable
mv BulkRenamer "$APP_NAME/Contents/MacOS/"
chmod +x "$APP_NAME/Contents/MacOS/BulkRenamer"

# Copy icon files
if [ -f "Resources/AppIcon.icns" ]; then
    echo "📦 Adding application icon..."
    cp Resources/AppIcon.icns "$APP_NAME/Contents/Resources/"
fi

if [ -f "Resources/AppIcon.png" ]; then
    echo "📦 Adding UI icon..."
    cp Resources/AppIcon.png "$APP_NAME/Contents/Resources/"
fi

# Create Info.plist with icon reference
cat > "$APP_NAME/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BulkRenamer</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.bulkrenamer.app</string>
    <key>CFBundleName</key>
    <string>Bulk Renaming Utility</string>
    <key>CFBundleDisplayName</key>
    <string>Bulk Renaming Utility</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
PLIST

echo ""
echo "✅ App Built Successfully!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo "🎨 Custom icon: AppIcon.icns"
echo ""
echo "🚀 To launch: open $APP_NAME"
echo ""
