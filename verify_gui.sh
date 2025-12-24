#!/bin/bash
echo "🔍 Verifying GUI App..."
echo ""

APP="BulkRenamer.app"

# Check if app exists
if [ ! -d "$APP" ]; then
    echo "❌ App not found!"
    exit 1
fi

# Check executable
EXEC="$APP/Contents/MacOS/BulkRenamer"
if [ ! -f "$EXEC" ]; then
    echo "❌ Executable not found!"
    exit 1
fi

# Check if executable
if [ ! -x "$EXEC" ]; then
    echo "❌ Not executable!"
    exit 1
fi

# Check file type
FILE_TYPE=$(file "$EXEC" | grep "Mach-O 64-bit executable arm64")
if [ -z "$FILE_TYPE" ]; then
    echo "❌ Not a valid macOS executable!"
    exit 1
fi

# Check Info.plist
if [ ! -f "$APP/Contents/Info.plist" ]; then
    echo "❌ Info.plist missing!"
    exit 1
fi

echo "✅ App structure: OK"
echo "✅ Executable: OK ($(ls -lh "$EXEC" | awk '{print $5}'))"
echo "✅ File type: arm64 Mach-O"
echo "✅ Info.plist: OK"
echo ""
echo "🎉 BulkRenamer.app is ready to use!"
echo ""
echo "To launch:"
echo "  • Double-click: BulkRenamer.app"
echo "  • Terminal: open BulkRenamer.app"
echo "  • Applications: cp -r BulkRenamer.app /Applications/"
echo ""
