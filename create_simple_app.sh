#!/bin/bash

echo "📦 Creating Simple macOS Launcher App..."

APP_NAME="BulkRenamer.app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove old app
rm -rf "$APP_NAME"

# Create app bundle structure
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

# Create the launcher script
cat > "$APP_NAME/Contents/MacOS/launch.command" << LAUNCHER
#!/bin/bash
cd "$SCRIPT_DIR"

# Check if build exists
if [ ! -f ".build/release/bulk-renamer" ]; then
    echo "Building Bulk Renamer..."
    swift build -c release
fi

# Run the renamer
.build/release/bulk-renamer
LAUNCHER

chmod +x "$APP_NAME/Contents/MacOS/launch.command"

# Create AppleScript wrapper
cat > "$APP_NAME/Contents/MacOS/BulkRenamer" << 'APPLESCRIPT'
#!/usr/bin/osascript
tell application "Terminal"
    activate
    set currentPath to POSIX path of ((path to me as text) & "::")
    set scriptPath to currentPath & "launch.command"
    do script quoted form of scriptPath
end tell
APPLESCRIPT

chmod +x "$APP_NAME/Contents/MacOS/BulkRenamer"

# Create Info.plist
cat > "$APP_NAME/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BulkRenamer</string>
    <key>CFBundleIdentifier</key>
    <string>com.bulkrenamer.cli</string>
    <key>CFBundleName</key>
    <string>Bulk Renamer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
PLIST

echo "✅ App created!"
echo ""
echo "📍 Location: $SCRIPT_DIR/$APP_NAME"
echo ""
echo "To use:"
echo "  1. Double-click $APP_NAME"
echo "  2. It will open Terminal and run the renamer"
echo ""
echo "To move to Applications:"
echo "  cp -r \"$APP_NAME\" /Applications/"
echo ""
