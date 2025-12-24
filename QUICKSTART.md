# Quick Start Guide

Get started with the Bulk File Renaming Utility in under 5 minutes!

## Installation (30 seconds)

```bash
cd Bulk-Renaming-Utility
swift build -c release
```

## Running the Utility (10 seconds)

```bash
swift run
```

Or if you built the release version:

```bash
.build/release/bulk-renamer
```

## Your First Rename (2 minutes)

### Step 1: Prepare a Test Folder

Create a test folder with some files:

```bash
# Create test directory
mkdir ~/test-rename
cd ~/test-rename

# Create some test files
touch photo1.jpg photo2.jpg photo3.jpg
touch document1.pdf document2.pdf
touch video1.mp4 video2.mp4
```

### Step 2: Launch and Select Directory

1. Run the utility: `swift run`
2. Select option `1` (Select Directory)
3. Enter path: `~/test-rename` (or drag & drop the folder)

### Step 3: Preview Your First Rename

1. Select option `2` (Preview Rename)
2. Try this pattern: `File_{counter:1,3}`
3. See the preview:

```
✓ 1. document1.pdf
   → File_001.pdf
✓ 2. document2.pdf
   → File_002.pdf
✓ 3. photo1.jpg
   → File_001.jpg
...
```

### Step 4: Execute the Rename

1. Select option `3` (Execute Rename)
2. Enter the same pattern: `File_{counter:1,3}`
3. Type `YES` to confirm
4. Files renamed! ✅

## Common Patterns to Try

### Add Date to Files
```
Pattern: {date:yyyy-MM-dd}_{name}
Result:  2025-11-15_photo1.jpg
```

### Numbered Series
```
Pattern: Photo_{counter:1,4}
Result:  Photo_0001.jpg, Photo_0002.jpg
```

### Keep Name, Add Counter
```
Pattern: {name}_{counter:1,2}
Result:  photo1_01.jpg, photo2_02.jpg
```

### Professional Format
```
Pattern: {parent}_{date:yyyy-MM-dd}_{counter:1,3}
Result:  test-rename_2025-11-15_001.jpg
```

## Next Steps

- 📖 Read [USAGE.md](USAGE.md) for detailed instructions
- 💡 Check [EXAMPLES.md](EXAMPLES.md) for real-world use cases
- 📋 View [README.md](README.md) for complete documentation
- ❓ Type `5` in the menu for pattern help

## Quick Reference Card

### Menu Options
```
1 - Select Directory
2 - Preview Rename
3 - Execute Rename
4 - Show Examples
5 - Show Pattern Help
0 - Exit
```

### Essential Tokens
```
{counter:1,3}         Sequential number (001, 002, 003)
{name}                Original filename
{date:yyyy-MM-dd}     Current date (2025-11-15)
{parent}              Parent folder name
{random:6}            Random 6-char string
```

### Safety Tips
- ✅ Always preview before executing
- ✅ Test on copies first
- ✅ Type "YES" exactly to confirm
- ⚠️ No undo feature - be careful!
- 💾 Keep backups of important files

## Need Help?

- In the utility: Select option `5` for pattern help
- Pattern not working? Type `help` when entering a pattern
- See examples: Select option `4` in the menu
- Full docs: Check README.md

## System-wide Installation (Optional)

To use `bulk-renamer` from anywhere:

```bash
make install
# Or manually:
swift build -c release
sudo cp .build/release/bulk-renamer /usr/local/bin/
```

Then simply run:
```bash
bulk-renamer
```

---

**You're all set!** 🎉 Start renaming files efficiently with powerful patterns.
