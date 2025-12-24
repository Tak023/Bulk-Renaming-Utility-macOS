# Usage Guide - Bulk File Renaming Utility

## Getting Started

### 1. Running the Application

```bash
# Navigate to project directory
cd Bulk-Renaming-Utility

# Run directly with Swift
swift run

# Or build and run the executable
swift build -c release
.build/release/bulk-renamer
```

### 2. Main Menu

When you launch the utility, you'll see:

```
╔═══════════════════════════════════════════════════════╗
║      BULK FILE RENAMING UTILITY                       ║
║      Version 1.0                                      ║
╚═══════════════════════════════════════════════════════╝

───────────────────────────────────────────────────────
📁 No directory selected
───────────────────────────────────────────────────────
1. Select Directory
2. Preview Rename Operations
3. Execute Rename
4. Show Examples
5. Show Pattern Help
0. Exit
───────────────────────────────────────────────────────
Enter your choice:
```

## Step-by-Step Workflow

### Step 1: Select a Directory

1. Choose option `1` from the main menu
2. Enter the full path to your directory, or drag & drop a folder into the terminal
3. The utility will confirm the selection and show the file count

**Example:**
```
Enter directory path: /Users/username/Photos/Vacation
✅ Directory selected: /Users/username/Photos/Vacation
📄 Found 125 file(s)
```

### Step 2: Preview Rename Operations

1. Choose option `2` from the main menu
2. Enter your desired naming pattern (see Pattern Reference below)
3. Review the preview showing how files will be renamed

**Example:**
```
Enter naming pattern: Vacation_{date:yyyy-MM-dd}_{counter:1,3}

════════════════════════════════════════════════════════════════════════════════
PREVIEW: 125 file(s) will be renamed
════════════════════════════════════════════════════════════════════════════════
✓ 1. IMG_1234.jpg
   → Vacation_2025-08-15_001.jpg
✓ 2. IMG_1235.jpg
   → Vacation_2025-08-15_002.jpg
✓ 3. IMG_1236.jpg
   → Vacation_2025-08-16_003.jpg
... and 122 more file(s)
════════════════════════════════════════════════════════════════════════════════
```

### Step 3: Execute Rename

1. Choose option `3` from the main menu
2. Enter the same naming pattern
3. Type `YES` to confirm the operation
4. Review the results

**Example:**
```
⚠️  You are about to rename 125 file(s)
Type 'YES' to confirm: YES

════════════════════════════════════════════════════════════════════════════════
✅ Successfully renamed: 125 file(s)
════════════════════════════════════════════════════════════════════════════════
```

## Pattern Reference

### Basic Patterns

#### Simple Counter
```
Pattern: file_{counter:1,3}
Input:   document.pdf, image.jpg, video.mp4
Output:  file_001.pdf, file_002.jpg, file_003.mp4
```

#### Keep Original Name with Counter
```
Pattern: {name}_{counter:1,2}
Input:   vacation.jpg, sunset.jpg
Output:  vacation_01.jpg, sunset_02.jpg
```

#### Text Prefix
```
Pattern: Project_Document_{counter:1,4}
Input:   file1.docx, file2.docx
Output:  Project_Document_0001.docx, Project_Document_0002.docx
```

### Date-Based Patterns

#### Current Date
```
Pattern: {date:yyyy-MM-dd}_{counter:1,3}
Input:   photo.jpg, image.png
Output:  2025-11-15_001.jpg, 2025-11-15_002.png
```

#### File Creation Date
```
Pattern: {created:yyyyMMdd}_{name}
Input:   (file created 2025-08-20) vacation.jpg
Output:  20250820_vacation.jpg
```

#### Date with Time
```
Pattern: Backup_{date:yyyy-MM-dd_HHmmss}
Input:   config.json
Output:  Backup_2025-11-15_143022.json
```

### Advanced Patterns

#### Parent Folder Name
```
Pattern: {parent}_{counter:1,3}
Input:   (in folder "ProjectX") file1.txt, file2.txt
Output:  ProjectX_001.txt, ProjectX_002.txt
```

#### File Size Information
```
Pattern: {name}_{size}
Input:   document.pdf (2.5 MB), image.jpg (1.2 MB)
Output:  document_2.5MB.pdf, image_1.2MB.jpg
```

#### Random Identifiers
```
Pattern: file_{random:6}
Input:   document.pdf, image.jpg
Output:  file_aB3xY9.pdf, file_kL8mN2.jpg
```

#### UUID
```
Pattern: {uuid}
Input:   file.txt
Output:  A1B2C3D4-E5F6-7890-ABCD-EF1234567890.txt
```

### Text Transformation Patterns

#### Uppercase
```
Pattern: {uppercase:photo}_{counter:1,3}
Output:  PHOTO_001.jpg, PHOTO_002.jpg
```

#### Lowercase
```
Pattern: {lowercase:IMAGE}_{counter:1,3}
Output:  image_001.jpg, image_002.jpg
```

#### Capitalized
```
Pattern: {capitalize:vacation photos}_{counter:1,2}
Output:  Vacation Photos_01.jpg, Vacation Photos_02.jpg
```

### Complex Patterns

#### Professional Photography
```
Pattern: {date:yyyy-MM-dd}_{parent}_{counter:1,4}_{name}
Input:   (in "Wedding_Smith") ceremony.jpg
Output:  2025-11-15_Wedding_Smith_0001_ceremony.jpg
```

#### Versioned Documents
```
Pattern: {name}_v{counter:1,2}_{date:yyyyMMdd}
Input:   report.docx
Output:  report_v01_20251115.docx, report_v02_20251115.docx
```

#### Archival System
```
Pattern: {created:yyyy}/{created:MM}/{parent}_{counter:1,5}
Input:   (created 2025-08-15, in "Photos") image.jpg
Output:  2025/08/Photos_00001.jpg
```

## Common Use Cases

### 1. Organize Photos from Camera
```
Pattern: Photo_{date:yyyy-MM-dd}_{counter:1,4}
Before:  DSC_0001.jpg, DSC_0002.jpg, DSC_0003.jpg
After:   Photo_2025-11-15_0001.jpg, Photo_2025-11-15_0002.jpg
```

### 2. Rename Project Files
```
Pattern: {parent}_Document_{counter:100,4}
Before:  (in "ProjectAlpha") file1.docx, file2.docx
After:   ProjectAlpha_Document_0100.docx, ProjectAlpha_Document_0101.docx
```

### 3. Create Numbered Series
```
Pattern: Episode_{counter:1,2}_{name}
Before:  intro.mp4, chapter1.mp4, chapter2.mp4
After:   Episode_01_intro.mp4, Episode_02_chapter1.mp4
```

### 4. Add Timestamps to Backups
```
Pattern: {name}_backup_{date:yyyyMMdd_HHmmss}
Before:  database.sql, config.json
After:   database_backup_20251115_143022.sql
```

### 5. Standardize Naming Convention
```
Pattern: {lowercase:{parent}}_{counter:1,3}_{lowercase:{name}}
Before:  (in "REPORTS") FILE1.PDF, Document2.PDF
After:   reports_001_file1.pdf, reports_002_document2.pdf
```

## Tips & Best Practices

### 1. Always Preview First
- Use option 2 to preview changes before executing
- Verify that patterns produce expected results
- Check for any naming conflicts

### 2. Use Adequate Padding
- For 10-99 files: use padding of 2 (`{counter:1,2}`)
- For 100-999 files: use padding of 3 (`{counter:1,3}`)
- For 1000+ files: use padding of 4 or more

### 3. Include Dates Strategically
- Use `{date:format}` for current organization
- Use `{created:format}` to preserve original file dates
- Choose date formats that sort well (`yyyy-MM-dd`)

### 4. Avoid Naming Conflicts
- Always include a counter for uniqueness
- Consider adding random components for batch operations
- Check preview for duplicate names

### 5. Preserve Important Information
- Use `{name}` to keep original filenames
- Include `{parent}` for context
- Add dates to maintain chronological order

## Troubleshooting

### Pattern Not Working as Expected

**Problem:** Text transforms not applying
```
Wrong:   {uppercase:test}_{counter:1,3}
Error:   The word "uppercase" becomes part of filename
```

**Solution:** Check syntax - transforms apply to literal text only
```
Correct: TEST_{counter:1,3}  (or use uppercase in actual text)
```

### Files Not Showing in Preview

**Check:**
1. Verify directory path is correct
2. Ensure you have read permissions
3. Confirm files exist (not subdirectories)
4. Check if files are hidden

### Rename Operation Fails

**Common Causes:**
1. **Destination file exists** - Modify pattern to ensure uniqueness
2. **No write permissions** - Check folder permissions
3. **Invalid filename characters** - Avoid: `/ \ : * ? " < > |`

## Advanced Usage

### Custom Date Formats

```swift
yyyy        // 4-digit year: 2025
yy          // 2-digit year: 25
MM          // Month: 01-12
MMM         // Month name: Jan, Feb
MMMM        // Full month: January
dd          // Day: 01-31
HH          // Hour (24h): 00-23
mm          // Minute: 00-59
ss          // Second: 00-59
```

**Examples:**
- `yyyy-MM-dd` → 2025-11-15
- `MMM dd, yyyy` → Nov 15, 2025
- `yyyyMMdd_HHmmss` → 20251115_143022
- `dd-MM-yy` → 15-11-25

### Combining Multiple Tokens

You can combine any tokens to create complex patterns:

```
Pattern: {parent}_{date:yyyy-MM}_{counter:1,4}_{lowercase:{name}}
```

This pattern includes:
- Parent folder name
- Year and month from file
- 4-digit counter
- Lowercase original filename

## Getting Help

- **In-app help**: Select option `5` from main menu
- **Examples**: Select option `4` from main menu
- **Pattern syntax**: Type `help` when entering a pattern
- **Documentation**: See README.md for full reference

## Safety Reminders

⚠️ **Important Safety Tips:**

1. **Test on copies first** - Always test on backup copies before running on important files
2. **Preview thoroughly** - Review the complete preview, not just the first few files
3. **Confirm carefully** - You must type "YES" exactly to confirm operations
4. **No undo feature** - Rename operations cannot be automatically undone
5. **Backup important files** - Always maintain backups of critical data

---

For more information, see the main README.md or run the utility and select option 5 for pattern help.
