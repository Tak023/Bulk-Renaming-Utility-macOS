# Troubleshooting: Files Not Displaying

## Issue
After selecting a folder, files don't display in the app.

## Quick Fixes to Try

### 1. Check macOS Permissions

The app needs permission to access folders. Try this:

```bash
# Remove quarantine
xattr -cr BulkRenamer.app

# Reopen
open BulkRenamer.app
```

### 2. Test with Simple Folder

I created a test folder for you:

```bash
# Navigate to test folder
open ~/test-bulk-rename
```

Then in the app:
1. Click "Choose Folder"
2. Select `test-bulk-rename` folder
3. Click "Select"

### 3. Check Console for Errors

```bash
# Open Console to see debug messages
open -a Console
```

In Console:
1. Click "Start" to begin logging
2. Filter for "BulkRenamer"
3. Open the app and select a folder
4. Look for messages like:
   - "Loading files from: ..."
   - "Loaded X files"
   - Or any error messages

### 4. Try Different Folders

Sometimes permissions vary by folder. Try:
- Desktop folder
- Documents folder
- Downloads folder
- The test folder at ~/test-bulk-rename

### 5. Grant Full Disk Access

macOS 26 may require explicit permissions:

1. Open **System Settings**
2. Go to **Privacy & Security**
3. Click **Full Disk Access**
4. Add **BulkRenamer.app**
   - Click the "+" button
   - Navigate to Bulk Renamer-Utility folder
   - Select BulkRenamer.app
   - Enable the toggle

### 6. Rebuild the App

```bash
cd /Users/mike/Projects/Git/Bulk-Renaming-Utility/Bulk-Renaming-Utility
./build_enhanced_gui.sh
open BulkRenamer.app
```

## What SHOULD Happen

When you select a folder, you should see:

```
Files in Directory (18)
─────────────────────────────
1. 📷 photo1.jpg    0 bytes
2. 📷 photo2.jpg    0 bytes
3. 📄 document1.pdf 0 bytes
...
```

## Checking if It's Working

After selecting a folder, look for:
1. ✅ Folder path displays
2. ✅ File count shows (e.g., "📄 18 files")
3. ✅ "Files in Directory" section appears
4. ✅ List of files with icons

## If Still Not Working

Try the CLI version which definitely works:

```bash
swift run
```

Then:
1. Select option 1 (Select Directory)
2. Enter: ~/test-bulk-rename
3. Files will display

Or let me know and I can add more debug output to see exactly what's happening!

## Common Issues

### Issue: "No files found in this directory"
**Solution**: The folder might only contain subdirectories, not files. Try a folder with actual files in it.

### Issue: Nothing happens when clicking "Choose Folder"
**Solution**:
```bash
# Check if app is executable
ls -l BulkRenamer.app/Contents/MacOS/BulkRenamer

# Should show: -rwxr-xr-x
# If not:
chmod +x BulkRenamer.app/Contents/MacOS/BulkRenamer
```

### Issue: App crashes when selecting folder
**Solution**: Rebuild with latest code
```bash
./build_enhanced_gui.sh
```

## Debug Information Needed

If nothing works, please provide:

1. **macOS Version**:
   ```bash
   sw_vers
   ```

2. **Console Output** (from Console.app after selecting folder)

3. **What happens** when you click "Choose Folder"

4. **Test folder contents**:
   ```bash
   ls -la ~/test-bulk-rename
   ```

This will help me diagnose the exact issue!
