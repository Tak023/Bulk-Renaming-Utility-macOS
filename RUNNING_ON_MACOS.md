# Running on macOS - Complete Guide

## 🎯 Current Status

You have **BulkRenamer.app** ready to use! This is a Terminal-based app (not a GUI window app).

## ✅ How to Use It NOW

### Option 1: Double-Click the App

```
1. Find: BulkRenamer.app
2. Double-click it
3. Terminal will open with the Bulk Renamer menu
4. Use it to rename files!
```

**First time?** macOS might ask for permission:
- Right-click → Open (instead of double-click)
- Click "Open" in the dialog

### Option 2: Run in Terminal

```bash
# Navigate to the project
cd /Users/mike/Projects/Git/Bulk-Renaming-Utility/Bulk-Renaming-Utility

# Run it
swift run
```

### Option 3: Install System-Wide

```bash
# Install the command
sudo cp .build/release/bulk-renamer /usr/local/bin/

# Run from anywhere
bulk-renamer
```

---

## 🖥️ Why No GUI Window?

The current app opens in **Terminal** because:

1. **No Xcode** - You don't have full Xcode installed (only Command Line Tools)
2. **Swift Limitation** - Building native GUI apps requires Xcode
3. **Works Great** - The CLI interface is fully functional and powerful!

---

## 🎨 Want a Real GUI App with Windows?

To build a proper macOS app with drag-and-drop and buttons:

### Step 1: Install Xcode (Required)

```
1. Open App Store
2. Search for "Xcode"
3. Click "Get" (free, but ~15GB download)
4. Wait for installation (can take 30-60 minutes)
```

### Step 2: Configure Xcode

After Xcode installs:

```bash
# Set Xcode as the active developer directory
sudo xcode-select --switch /Applications/Xcode.app

# Install additional components
xcode-select --install

# Verify installation
xcodebuild -version
```

### Step 3: I Can Build the GUI

Once Xcode is installed, let me know and I'll create a proper SwiftUI GUI app with:

- ✨ Native macOS window
- 🎯 Drag & drop folder selection
- 👁️ Visual preview of renames
- 🖱️ Click buttons (no typing commands)
- 📋 Quick pattern templates

---

## 📝 What You Have vs. What's Possible

### Current (Terminal-Based)

```
✅ Works without Xcode
✅ Fully functional
✅ All features available
✅ Lightweight
❌ Opens in Terminal window
❌ Text-based interface
```

### Future (GUI with Xcode)

```
✅ Native macOS window
✅ Drag & drop folders
✅ Visual previews
✅ Click buttons
✅ Modern interface
❌ Requires Xcode (15GB+)
```

---

## 🚀 Quick Start (Use It Now!)

### Try It Right Now:

```bash
# 1. Navigate to project
cd /Users/mike/Projects/Git/Bulk-Renaming-Utility/Bulk-Renaming-Utility

# 2. Run the app
swift run

# 3. Follow the menu:
#    1 - Select a folder
#    2 - Preview rename with a pattern
#    3 - Execute rename
```

### Example Session:

```
1. Select Directory
   Enter: ~/Desktop/Photos

2. Preview Rename Operations
   Pattern: Photo_{counter:1,4}
   (See preview of all renames)

3. Execute Rename
   Type: YES
   (Files renamed!)
```

---

## 🔧 Troubleshooting

### "BulkRenamer.app won't open"

```bash
# Remove quarantine attribute
xattr -cr BulkRenamer.app

# Then double-click again
open BulkRenamer.app
```

### "Permission denied"

```bash
# Make executable
chmod +x BulkRenamer.app/Contents/MacOS/BulkRenamer
chmod +x BulkRenamer.app/Contents/MacOS/launch.command
```

### "Swift not found"

Install Command Line Tools:
```bash
xcode-select --install
```

### "Nothing happens when double-clicking"

Try opening manually:
```bash
open BulkRenamer.app
```

Or use Terminal directly:
```bash
swift run
```

---

## 📦 Installation Options

### A. Move to Applications Folder

```bash
# Copy the app
cp -r BulkRenamer.app /Applications/

# Find it in Spotlight
# Press ⌘+Space, type "Bulk Renamer"
```

### B. Create Desktop Shortcut

```bash
# Link to Desktop
ln -s "$(pwd)/BulkRenamer.app" ~/Desktop/BulkRenamer.app
```

### C. Add to Dock

```
1. Open BulkRenamer.app
2. Right-click icon in Dock
3. Options → Keep in Dock
```

---

## 🎓 Learning the Interface

### Main Menu

```
╔═══════════════════════════════════════╗
║   BULK FILE RENAMING UTILITY          ║
╚═══════════════════════════════════════╝

1. Select Directory        ← Choose folder
2. Preview Rename          ← See changes
3. Execute Rename          ← Apply changes
4. Show Examples           ← Pattern ideas
5. Show Pattern Help       ← Token reference
0. Exit                    ← Quit
```

### Pattern Tokens

```
{counter:1,3}              → 001, 002, 003
{name}                     → original_filename
{date:yyyy-MM-dd}          → 2025-11-15
{parent}                   → folder_name
{random:6}                 → aB3xY9
```

See EXAMPLES.md for dozens of real-world patterns!

---

## ⚡ Performance

The Terminal version is actually **faster** than GUI apps because:
- No rendering overhead
- Direct file system access
- Batch operations
- Minimal memory usage

---

## 🔄 Rebuilding the App

If you make changes to the code:

```bash
# Rebuild the app
./create_simple_app.sh

# Or rebuild just the executable
swift build -c release
```

---

## 📚 Additional Resources

- **QUICKSTART.md** - 5-minute tutorial
- **USAGE.md** - Detailed usage guide
- **EXAMPLES.md** - 50+ pattern examples
- **README.md** - Full documentation

---

## ❓ macOS Version Info

You mentioned "**macOS Tahoe 26.2**" - this doesn't exist!

Current macOS versions:
- macOS 13 = Ventura
- macOS 14 = Sonoma
- macOS 15 = Sequoia (latest, 2024)

Check your version:
```bash
sw_vers
```

The app works on macOS 13+ (any Apple Silicon or Intel Mac).

---

## 🎯 Bottom Line

**You can use it RIGHT NOW:**

```bash
# Option A: Double-click
open BulkRenamer.app

# Option B: Terminal
swift run

# Option C: System command
bulk-renamer  (after running: make install)
```

**Want GUI with windows?**
→ Install Xcode from App Store (free)
→ Let me know when ready
→ I'll build the SwiftUI GUI version

---

**Ready to rename files!** 🚀

Try it: `swift run` or double-click `BulkRenamer.app`
