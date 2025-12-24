# Enhanced GUI Features Guide

## ✨ What's New

Your **BulkRenamer.app** now has enhanced file display and preview features!

## 🎯 How It Works

### Step 1: Select Folder → Files Display Immediately

When you click **"Choose Folder"** and select a directory:

```
✅ Folder path appears
✅ File count shows (e.g., "📄 125 files")
✅ ALL FILES IN THE FOLDER DISPLAY AUTOMATICALLY
```

You'll see a scrollable list showing:
- 📄 File number (1, 2, 3...)
- 📁 File icon (photo, video, document, etc.)
- 📝 Complete filename
- 📊 File size (KB, MB, GB)

**Shows up to 50 files** by default with "... and X more files" message.

### Step 2: Enter Pattern

Type your naming pattern or use Quick Pattern buttons:
- `Photo_{counter:1,4}`
- `{date:yyyy-MM-dd}_{counter:1,3}`
- `{name}_{counter:1,2}`
- Etc.

### Step 3: Preview Changes → See OLD → NEW

Click **"Preview Changes"** and you'll see:

```
For each file:
┌─────────────────────────────────────┐
│ 1. 🔴 IMG_1234.jpg (strikethrough)  │
│    ↓                                │
│    🟢 Photo_0001.jpg (bold)         │
└─────────────────────────────────────┘
```

**Each preview entry shows:**
- ❌ OLD filename (red icon, strikethrough)
- ⬇️ Arrow indicating change
- ✅ NEW filename (green icon, bold)

### Step 4: Rename Files

Click **"Rename Files"** → Confirm → Done!

**After renaming:**
- Files automatically reload
- You can see the new filenames
- Status shows success count

---

## 📋 Complete Workflow Example

### Example: Renaming Vacation Photos

**1. Click "Choose Folder"**
   - Select: `~/Pictures/Vacation`
   - **Immediately see:**
     ```
     Files in Directory (125)
     ─────────────────────────────
     1. 📷 IMG_1234.jpg    2.5 MB
     2. 📷 IMG_1235.jpg    3.1 MB
     3. 📷 IMG_1236.jpg    2.8 MB
     ... and 122 more files
     ```

**2. Enter Pattern**
   - Type: `Vacation_{date:yyyy-MM-dd}_{counter:1,3}`
   - Or click "Date + Counter" Quick Pattern

**3. Click "Preview Changes"**
   - **See transformation:**
     ```
     Rename Preview (125 files)
     ─────────────────────────────────────
     1. 🔴 IMG_1234.jpg (crossed out)
        ↓
        🟢 Vacation_2025-08-15_001.jpg

     2. 🔴 IMG_1235.jpg (crossed out)
        ↓
        🟢 Vacation_2025-08-15_002.jpg

     3. 🔴 IMG_1236.jpg (crossed out)
        ↓
        🟢 Vacation_2025-08-16_003.jpg
     ... and 122 more files
     ```

**4. Click "Rename Files"**
   - Confirm dialog appears
   - Click "Rename Files"
   - ✅ Success! Files renamed
   - **Files automatically reload** showing new names

---

## 🎨 Visual Elements

### File Type Icons

The app shows different icons based on file type:

| Type | Icon | Extensions |
|------|------|------------|
| Photos | 📷 | .jpg, .png, .heic, .gif |
| Videos | 🎬 | .mp4, .mov, .avi, .mkv |
| Audio | 🎵 | .mp3, .wav, .m4a |
| PDFs | 📄 | .pdf |
| Archives | 📦 | .zip, .rar, .7z |
| Text | 📝 | .txt, .md |
| Other | 📄 | All other files |

### Color Coding

**File List (Before Preview):**
- Blue icons for all files
- Gray text for file sizes

**Preview (OLD → NEW):**
- 🔴 Red icon + strikethrough = Original filename (being replaced)
- ⬇️ Blue arrow = Change indicator
- 🟢 Green icon + bold = New filename (final result)

### Status Messages

| Icon | Color | Meaning |
|------|-------|---------|
| ✅ | Green | Success |
| ❌ | Red | Error |
| ℹ️ | Blue | Information |
| ⚠️ | Orange | Warning |

---

## 🔄 Auto-Reload Feature

**After renaming files:**
- The app automatically reloads the directory
- You see the NEW filenames in the file list
- Preview is cleared
- Ready for next operation!

---

## 📊 Display Limits

### File List (Initial Display)
- Shows first **50 files**
- Displays: "... and X more files" if more exist
- Scrollable list

### Preview List
- Shows first **50 rename operations**
- Displays: "... and X more files" if more exist
- Scrollable list
- Each entry shows full OLD → NEW transformation

### Performance
- Fast loading for 1000+ files
- Instant preview generation
- Smooth scrolling

---

## 💡 Pro Tips

### 1. Review Files First
Select a folder and review the file list **before** entering a pattern. This helps you:
- See what types of files are present
- Check file extensions
- Understand the current naming

### 2. Use Preview Extensively
**Always preview** before renaming:
- Scroll through the entire preview
- Check for any unexpected results
- Verify the pattern works correctly

### 3. Quick Pattern Shortcuts
Use the Quick Pattern buttons to:
- Get started quickly
- Learn pattern syntax
- Modify and customize

### 4. Clear Preview Button
If you want to change your pattern:
- Click "Clear Preview" (X button next to preview title)
- Modify your pattern
- Click "Preview Changes" again

### 5. File Size Reference
The file sizes help you:
- Identify large files
- Spot duplicates
- Verify you're in the right folder

---

## 🎯 Interface Layout

```
┌────────────────────────────────────────────┐
│         Bulk File Renamer                  │
│   Rename multiple files with patterns      │
├────────────────────────────────────────────┤
│                                            │
│  📁 Select Directory                       │
│  ┌──────────────────────────────────────┐ │
│  │ 📂 Vacation         [Choose Folder]  │ │
│  │ /Users/mike/Pictures/Vacation        │ │
│  │ 📄 125 files                         │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  📋 Files in Directory (125)               │
│  ┌──────────────────────────────────────┐ │
│  │ 1. 📷 IMG_1234.jpg        2.5 MB    │ │
│  │ 2. 📷 IMG_1235.jpg        3.1 MB    │ │
│  │ 3. 📷 IMG_1236.jpg        2.8 MB    │ │
│  │ ... (scrollable)                     │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  📝 Naming Pattern               [?]       │
│  ┌──────────────────────────────────────┐ │
│  │ Vacation_{date:yyyy-MM-dd}_{counter} │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  Quick Patterns:                           │
│  [Counter] [Date+Counter] [Keep Name]...  │
│                                            │
│  [Preview Changes]  [Rename Files]         │
│                                            │
│  ✅ Preview ready - Review 125 operations  │
│                                            │
│  🔄 Rename Preview (125 files)      [X]    │
│  ┌──────────────────────────────────────┐ │
│  │ 1. 🔴 IMG_1234.jpg                   │ │
│  │    ↓                                 │ │
│  │    🟢 Vacation_2025-08-15_001.jpg    │ │
│  │                                      │ │
│  │ 2. 🔴 IMG_1235.jpg                   │ │
│  │    ↓                                 │ │
│  │    🟢 Vacation_2025-08-15_002.jpg    │ │
│  │ ... (scrollable)                     │ │
│  └──────────────────────────────────────┘ │
│                                            │
└────────────────────────────────────────────┘
```

---

## 🚀 Quick Reference

### What Displays When

| Action | What You See |
|--------|-------------|
| **Select Folder** | → File list appears immediately |
| **Enter Pattern** | → Nothing changes (file list stays) |
| **Click Preview** | → OLD → NEW list appears below |
| **Click Rename** | → Confirmation → Execute → Reload files |
| **After Rename** | → File list shows NEW names |

### Button States

| Button | Enabled When |
|--------|-------------|
| Choose Folder | Always |
| Preview Changes | Folder selected + Pattern entered |
| Rename Files | Preview generated |
| Clear Preview | Preview is showing |
| Help (?) | Always |

---

## 📖 See Also

- **EXAMPLES.md** - 50+ pattern examples
- **USAGE.md** - Detailed usage guide
- **MACOS_26_GUI.md** - macOS 26.2 specific info
- **QUICKSTART.md** - 5-minute tutorial

---

**Enjoy the enhanced file display and preview features!** 🎉

The app now shows you **exactly** what will happen before any files are renamed.
