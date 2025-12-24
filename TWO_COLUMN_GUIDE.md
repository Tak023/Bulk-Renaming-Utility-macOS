# Two-Column Layout Guide

## ✅ What You Have Now

Your **BulkRenamer.app** now features a clean **two-column layout** that makes it crystal clear what's happening!

## 🎨 The Layout

```
┌──────────────────────────────────────────────────────────────┐
│                    Bulk File Renamer                         │
├──────────────────────────────────────────────────────────────┤
│ 📁 Select Directory                                          │
│ ✏️ Naming Pattern                                            │
│ [Preview Changes]  [Rename Files]                           │
├──────────────────────────────────────────────────────────────┤
│                      File List                               │
│ ┌────────────────────────┬──────────────────────────────┐   │
│ │ ORIGINAL FILE          │ NEW FILE                     │   │
│ ├────────────────────────┼──────────────────────────────┤   │
│ │ 1. 📷 photo1.jpg       │ —                            │   │
│ │ 2. 📷 photo2.jpg       │ —                            │   │
│ │ 3. 📄 document1.pdf    │ —                            │   │
│ └────────────────────────┴──────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## 📋 How It Works

### Step 1: Select Folder
1. Click **"Choose Folder"** button
2. Navigate to your folder
3. Click **"Select"**

**Result:**
```
┌────────────────────────┬──────────────────────────────┐
│ ORIGINAL FILE          │ NEW FILE                     │
├────────────────────────┼──────────────────────────────┤
│ 1. 📷 photo1.jpg       │ —                            │
│ 2. 📷 photo2.jpg       │ —                            │
│ 3. 📷 photo3.jpg       │ —                            │
│ 4. 📄 document1.pdf    │ —                            │
│ 5. 📄 document2.pdf    │ —                            │
└────────────────────────┴──────────────────────────────┘
```

✅ **LEFT column populates** with original filenames
✅ **RIGHT column shows** dashes (—) = no preview yet

### Step 2: Enter Pattern
Type a pattern or use Quick Pattern buttons:
- `Photo_{counter:1,4}`
- `{date:yyyy-MM-dd}_{counter:1,3}`
- `{parent}_{name}_{counter:1,2}`

### Step 3: Click "Preview Changes"

**Result:**
```
┌────────────────────────┬──────────────────────────────┐
│ ORIGINAL FILE          │ NEW FILE                     │
├────────────────────────┼──────────────────────────────┤
│ 1. 📷 photo1.jpg       │ ✓ Photo_0001.jpg             │
│ 2. 📷 photo2.jpg       │ ✓ Photo_0002.jpg             │
│ 3. 📷 photo3.jpg       │ ✓ Photo_0003.jpg             │
│ 4. 📄 document1.pdf    │ ✓ Photo_0004.pdf             │
│ 5. 📄 document2.pdf    │ ✓ Photo_0005.pdf             │
└────────────────────────┴──────────────────────────────┘
```

✅ **LEFT column** = Original filenames (unchanged)
✅ **RIGHT column** = New filenames with green checkmark (✓)

### Step 4: Review Changes
Scroll through the list to verify:
- Every file has a new name
- New names follow your pattern
- No conflicts or duplicates

### Step 5: Click "Rename Files"
1. Confirmation dialog appears
2. Click **"Rename Files"** to confirm
3. Files are renamed!
4. Columns reload with new current names

## 🎯 Visual Guide

### Before Preview
```
Left Column: ORIGINAL FILE    Right Column: NEW FILE
─────────────────────────    ──────────────────────
1. 📷 IMG_1234.jpg            —
2. 📷 IMG_1235.jpg            —
3. 📷 IMG_1236.jpg            —
```

### After Preview
```
Left Column: ORIGINAL FILE    Right Column: NEW FILE
─────────────────────────    ─────────────────────────────
1. 📷 IMG_1234.jpg            ✓ Vacation_2025-11-15_001.jpg
2. 📷 IMG_1235.jpg            ✓ Vacation_2025-11-15_002.jpg
3. 📷 IMG_1236.jpg            ✓ Vacation_2025-11-15_003.jpg
```

### After Rename
```
Left Column: ORIGINAL FILE              Right Column: NEW FILE
───────────────────────────────────    ──────────────────
1. 📷 Vacation_2025-11-15_001.jpg      —
2. 📷 Vacation_2025-11-15_002.jpg      —
3. 📷 Vacation_2025-11-15_003.jpg      —
```
(Columns reset - files now show their new names in left column)

## 🎨 Column Details

### Left Column: ORIGINAL FILE
**Shows:**
- Row number (1, 2, 3...)
- File icon (📷 photos, 📄 docs, 🎬 videos)
- Current filename

**Always displays:**
- When folder is selected
- Before preview
- After preview
- After rename

### Right Column: NEW FILE
**Shows:**
- Dash (—) = No preview generated yet
- ✓ + New filename = Preview generated
- Dash (—) after rename = Reset state

**States:**
1. **Empty state**: No folder selected
2. **Initial state**: Files loaded, shows dashes
3. **Preview state**: New names with checkmarks
4. **After rename**: Dashes (reset)

## 🔄 Clear Preview Button

Located in the header when preview is active:
```
File List (18 files)          [Clear Preview ×]
```

Click to:
- Clear the right column
- Go back to dash (—) state
- Modify pattern and preview again

## 📊 Features

### ✅ What Works
- Instant file loading in left column
- Side-by-side comparison
- Scrollable for many files
- Color-coded headers (blue = original, green = new)
- Alternating row colors for readability
- File type icons
- Clear visual indicators

### ✅ Status Messages
- "✅ Loaded 18 file(s)"
- "👁️ Preview ready - New filenames shown in right column"
- "✅ Successfully renamed 18 files!"

## 💡 Pro Tips

### 1. Review Before Renaming
- Scroll through ENTIRE list
- Check every file in both columns
- Look for unexpected patterns

### 2. Use Clear Preview
- Test different patterns
- Click "Clear Preview" between tests
- Find the perfect naming scheme

### 3. Pattern Testing
- Start with simple patterns
- Use Quick Pattern buttons
- Build complexity gradually

### 4. Large File Lists
- Box scrolls smoothly
- All files shown (no limit)
- Numbers help track position

## 🚀 Quick Start Example

**Scenario:** Rename vacation photos

1. **Click "Choose Folder"**
   - Select: ~/Pictures/Vacation2025

2. **Left column fills:**
   ```
   ORIGINAL FILE
   ─────────────────
   1. IMG_5432.jpg
   2. IMG_5433.jpg
   3. IMG_5434.jpg
   ```

3. **Enter pattern:**
   ```
   Vacation_{date:yyyy-MM-dd}_{counter:1,3}
   ```

4. **Click "Preview Changes"**
   ```
   ORIGINAL FILE      NEW FILE
   ─────────────────  ───────────────────────────────
   1. IMG_5432.jpg    ✓ Vacation_2025-08-15_001.jpg
   2. IMG_5433.jpg    ✓ Vacation_2025-08-15_002.jpg
   3. IMG_5434.jpg    ✓ Vacation_2025-08-16_003.jpg
   ```

5. **Review and click "Rename Files"**

6. **Done!** Files renamed.

## 🎯 Visual Indicators

| Icon | Meaning |
|------|---------|
| 📷 | Photo file |
| 🎬 | Video file |
| 📄 | Document |
| 📦 | Archive |
| 🎵 | Audio |
| — | No preview yet |
| ✓ | Preview generated |
| Blue header | Original files |
| Green header | New files |

## 📖 See Also

- **EXAMPLES.md** - Pattern examples
- **USAGE.md** - Detailed usage
- **MACOS_26_GUI.md** - macOS 26.2 setup
- **QUICKSTART.md** - Quick tutorial

---

**The two-column layout makes bulk renaming clear and safe!**

You can always see EXACTLY what will happen before any files are renamed.
