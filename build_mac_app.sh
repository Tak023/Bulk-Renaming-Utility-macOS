#!/bin/bash

echo "🔨 Building Bulk Renamer macOS Application..."

# Build the CLI version
echo "📦 Step 1: Building executable..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="BulkRenamer.app"
APP_PATH="$APP_NAME/Contents"

echo "📁 Step 2: Creating app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$APP_PATH/MacOS"
mkdir -p "$APP_PATH/Resources"

# Copy executable
echo "📋 Step 3: Copying executable..."
cp .build/release/bulk-renamer "$APP_PATH/MacOS/BulkRenamer"
chmod +x "$APP_PATH/MacOS/BulkRenamer"

# Create Info.plist
echo "📝 Step 4: Creating Info.plist..."
cat > "$APP_PATH/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>BulkRenamer</string>
    <key>CFBundleIdentifier</key>
    <string>com.bulkrenamer.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Bulk Renamer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# Create a launcher script that opens Terminal
echo "🚀 Step 5: Creating launcher script..."
cat > "$APP_PATH/MacOS/launcher.sh" << 'LAUNCHER'
#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
osascript -e "tell application \"Terminal\" to do script \"cd '$DIR' && ./BulkRenamer; exit\""
LAUNCHER

chmod +x "$APP_PATH/MacOS/launcher.sh"

# Update executable to be the launcher
mv "$APP_PATH/MacOS/BulkRenamer" "$APP_PATH/MacOS/BulkRenamerBin"
mv "$APP_PATH/MacOS/launcher.sh" "$APP_PATH/MacOS/BulkRenamer"

# Update the launcher to point to the binary
cat > "$APP_PATH/MacOS/BulkRenamer" << 'LAUNCHER'
#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
osascript -e "tell application \"Terminal\" to do script \"'$DIR/BulkRenamerBin'; exit\""
LAUNCHER

chmod +x "$APP_PATH/MacOS/BulkRenamer"

echo "✅ Application created successfully!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo ""
echo "To use:"
echo "  • Double-click $APP_NAME to open in Terminal"
echo "  • Or drag it to /Applications folder"
echo "  • Or run: open $APP_NAME"
echo ""
