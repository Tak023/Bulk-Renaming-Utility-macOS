# Installation Guide - Run on macOS

## Three Ways to Run This Application

### ✅ Option 1: Double-Click macOS App (EASIEST)

**I've already created this for you!**

1. **The app is ready**: `BulkRenamer.app`
2. **Double-click it** to launch
3. **Or drag to Applications folder**:
   ```bash
   cp -r BulkRenamer.app /Applications/
   ```
4. **Find it in Launchpad** or Spotlight

**To rebuild the app anytime**:
```bash
./build_mac_app.sh
```

### ⚡ Option 2: Install Command-Line Tool

Run from anywhere in Terminal:

```bash
# Install to your system
sudo cp .build/release/bulk-renamer /usr/local/bin/

# Now run from anywhere
bulk-renamer
```

Or use the Makefile:
```bash
make install
bulk-renamer
```

### 🛠 Option 3: Run Directly (No Installation)

```bash
# Run immediately
swift run

# Or build first, then run
swift build -c release
.build/release/bulk-renamer
```

---

## Quick Reference

### What You Have Now

```
BulkRenamer.app          ← Double-click this!
.build/release/bulk-renamer  ← Command-line version
build_mac_app.sh         ← Rebuilds the app
```

### File Locations After Installation

| Method | Location | How to Run |
|--------|----------|------------|
| macOS App | `/Applications/BulkRenamer.app` | Double-click or Spotlight |
| CLI Tool | `/usr/local/bin/bulk-renamer` | Type `bulk-renamer` in Terminal |
| Local | Current directory | `./build_mac_app.sh` then open app |

---

## Detailed Installation Instructions

### Installing the macOS App

#### Method 1: Finder (GUI)
1. Open Finder
2. Navigate to this folder
3. Drag `BulkRenamer.app` to your Applications folder
4. Find it in Launchpad or Spotlight (⌘ + Space, type "Bulk Renamer")

#### Method 2: Terminal
```bash
# Copy to Applications
cp -r BulkRenamer.app /Applications/

# Open from anywhere
open /Applications/BulkRenamer.app

# Or add to Dock
open /Applications/BulkRenamer.app
# Then right-click icon → Options → Keep in Dock
```

### Installing the Command-Line Tool

```bash
# Build release version
swift build -c release

# Install system-wide
sudo cp .build/release/bulk-renamer /usr/local/bin/

# Verify installation
which bulk-renamer
bulk-renamer
```

---

## First Run Setup

### macOS Security (First Time Only)

If you see "BulkRenamer.app can't be opened":

1. **Right-click** the app → **Open**
2. Click **Open** in the dialog
3. macOS will remember this choice

Or via Terminal:
```bash
xattr -cr BulkRenamer.app
open BulkRenamer.app
```

### Granting Terminal Permissions

The app may ask for:
- **Full Disk Access** (to rename files)
- **Files and Folders** access

To grant:
1. Open **System Settings** → **Privacy & Security**
2. Find **Files and Folders** or **Full Disk Access**
3. Enable for **Terminal** or **BulkRenamer**

---

## Testing Your Installation

### Test the macOS App
```bash
# Open the app
open BulkRenamer.app

# Create test files
mkdir ~/test-rename
touch ~/test-rename/file{1..5}.txt

# Use the app to rename them!
```

### Test the CLI Tool
```bash
# If installed system-wide
bulk-renamer

# Or run locally
swift run
```

---

## Rebuilding the App

If you make changes to the code:

```bash
# Rebuild everything
./build_mac_app.sh

# Or manually
swift build -c release
cp .build/release/bulk-renamer BulkRenamer.app/Contents/MacOS/BulkRenamerBin
```

---

## Uninstallation

### Remove the macOS App
```bash
rm -rf /Applications/BulkRenamer.app
```

### Remove the CLI Tool
```bash
sudo rm /usr/local/bin/bulk-renamer
```

### Clean Build Files
```bash
swift package clean
rm -rf .build
rm -rf BulkRenamer.app
```

---

## Troubleshooting

### "BulkRenamer.app is damaged"
```bash
xattr -cr BulkRenamer.app
```

### "Permission denied" when running
```bash
chmod +x BulkRenamer.app/Contents/MacOS/BulkRenamer
```

### Command not found: bulk-renamer
```bash
# Check if installed
ls -l /usr/local/bin/bulk-renamer

# Reinstall if needed
sudo cp .build/release/bulk-renamer /usr/local/bin/
```

### Swift not found
Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### Build fails
```bash
# Clean and rebuild
swift package clean
swift build -c release
```

---

## Creating an Installer Package (.pkg)

Want to distribute to others? Create a .pkg:

```bash
# Install pkgbuild (comes with Xcode)
pkgbuild --root BulkRenamer.app \
         --identifier com.bulkrenamer.app \
         --version 1.0 \
         --install-location /Applications/BulkRenamer.app \
         BulkRenamer.pkg
```

Then share `BulkRenamer.pkg` with others!

---

## What's Installed Where

```
macOS App:
  /Applications/BulkRenamer.app
    └── Contents/
        ├── Info.plist
        ├── MacOS/
        │   ├── BulkRenamer (launcher)
        │   └── BulkRenamerBin (actual program)
        └── Resources/

CLI Tool:
  /usr/local/bin/bulk-renamer

Source Code:
  ~/Projects/Git/Bulk-Renaming-Utility/
```

---

## Platform Compatibility

✅ **Supported**:
- macOS 13.0 (Ventura) or later
- macOS 14.0 (Sonoma)
- macOS 15.0 (Sequoia)
- Apple Silicon (M1, M2, M3, M4) - Native
- Intel Macs - Native

❌ **Not Supported**:
- macOS 12 or earlier (requires Swift 5.9+)
- iOS/iPadOS (different file system APIs)
- Windows/Linux (macOS-specific APIs used)

---

## Next Steps

1. ✅ You have `BulkRenamer.app` ready to use
2. 📱 Move it to Applications folder
3. 🎯 Try it on some test files
4. 📚 Read [QUICKSTART.md](QUICKSTART.md) for usage
5. 💡 Check [EXAMPLES.md](EXAMPLES.md) for patterns

**Ready to go!** Double-click `BulkRenamer.app` to start renaming files.
