# Bulk File Renaming Utility

A powerful, flexible Swift-based command-line utility for bulk renaming files with advanced pattern-based naming capabilities.

## Features

- **Flexible Pattern System**: Create custom naming patterns using powerful tokens
- **Interactive CLI**: User-friendly command-line interface with previews
- **Safe Operations**: Preview changes before executing with confirmation prompts
- **Multiple Tools**: Counter, date formatting, text transforms, random IDs, and more
- **Error Handling**: Comprehensive error checking and reporting
- **Cross-platform**: Works on macOS (requires Swift 5.9+)

## Installation

### Option 1: macOS Application (Easiest) ⭐

**Double-click to run!**

```bash
# Build the macOS app
./build_mac_app.sh

# Open the app
open BulkRenamer.app

# Or move to Applications
cp -r BulkRenamer.app /Applications/
```

### Option 2: Command-Line Tool

```bash
# Build and install system-wide
swift build -c release
sudo cp .build/release/bulk-renamer /usr/local/bin/

# Run from anywhere
bulk-renamer
```

### Option 3: Run Directly (Development)

```bash
swift run
```

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

## Quick Start

1. **Launch the utility**:
   ```bash
   swift run
   ```

2. **Select a directory**: Choose option 1 and enter the folder path

3. **Preview rename**: Use option 2 and enter a naming pattern

4. **Execute rename**: Confirm and execute with option 3

## Naming Pattern Tokens

### Counters
- `{counter:start,padding}` - Sequential numbers
  - Example: `{counter:1,3}` → `001`, `002`, `003`
  - Example: `{counter:100,4}` → `0100`, `0101`, `0102`

### File Information
- `{name}` or `{original}` - Original filename (without extension)
- `{ext}` or `{extension}` - File extension
- `{parent}` - Parent folder name
- `{size}` - File size (human-readable format)

### Dates
- `{date:format}` - File modification date
- `{created:format}` or `{creation:format}` - File creation date

Date format examples:
- `yyyy-MM-dd` → `2025-11-15`
- `yyyyMMdd_HHmmss` → `20251115_143022`
- `MMM-dd-yy` → `Nov-15-25`
- `yyyy/MM/dd` → `2025/11/15`

### Text Transformations
- `{upper:text}` or `{uppercase:text}` - Convert to UPPERCASE
- `{lower:text}` or `{lowercase:text}` - Convert to lowercase
- `{capitalize:text}` or `{title:text}` - Capitalize First Letters

### Random & Unique Identifiers
- `{random:length}` - Random alphanumeric string
  - Example: `{random:8}` → `aB3xY9mK`
- `{uuid}` - Unique UUID identifier
  - Example: `{uuid}` → `A1B2C3D4-E5F6-7890-ABCD-EF1234567890`

## Pattern Examples

### Example 1: Simple Counter
```
Pattern: Photo_{counter:1,4}
Result:  Photo_0001.jpg, Photo_0002.jpg, Photo_0003.jpg
```

### Example 2: Date-based Naming
```
Pattern: {date:yyyy-MM-dd}_{counter:1,3}
Result:  2025-11-15_001.jpg, 2025-11-15_002.jpg
```

### Example 3: Project Organization
```
Pattern: {parent}_{date:yyyyMMdd}_{counter:1,3}
Result:  ProjectName_20251115_001.jpg
```

### Example 4: With Text Transforms
```
Pattern: {upper:prefix}_{counter:1,3}
Result:  PREFIX_001.jpg, PREFIX_002.jpg
```

### Example 5: Keep Original with Counter
```
Pattern: {name}_{counter:1,2}
Result:  vacation_01.jpg, vacation_02.jpg
```

### Example 6: Complex Professional Pattern
```
Pattern: {date:yyyy-MM-dd}_{parent}_{counter:100,4}_{name}
Result:  2025-11-15_Photos_0100_sunset.jpg
```

### Example 7: Random Identifiers
```
Pattern: img_{random:6}_{counter:1,3}
Result:  img_aB3xY9_001.jpg, img_kL8mN2_002.jpg
```

## Usage Examples

### Rename vacation photos with dates
```
Pattern: Vacation_{date:yyyy-MM-dd}_{counter:1,3}
Before:  IMG_1234.jpg, IMG_1235.jpg
After:   Vacation_2025-11-15_001.jpg, Vacation_2025-11-15_002.jpg
```

### Organize project files
```
Pattern: {parent}_{counter:1,4}_{name}
Before:  (in folder "Report") draft.pdf, final.pdf
After:   Report_0001_draft.pdf, Report_0002_final.pdf
```

### Create timestamped backups
```
Pattern: {name}_backup_{date:yyyyMMdd_HHmmss}
Before:  config.json
After:   config_backup_20251115_143022.json
```

## Advanced Features

### Programmatic API

You can also use the renaming engine programmatically:

```swift
import Foundation

let renamer = FileRenamer()
let directoryURL = URL(fileURLWithPath: "/path/to/files")

// Get files
let files = try renamer.getFiles(from: directoryURL)

// Create pattern using builder
let pattern = PatternBuilder()
    .text("Photo_")
    .counter(start: 1, padding: 3)
    .text("_")
    .date(format: "yyyy-MM-dd")
    .build()

// Preview operations
let operations = renamer.previewRename(files: files, pattern: pattern)

// Execute
let result = try renamer.executeRename(operations: operations)
print("Renamed \(result.successful) files")
```

### Pattern Builder API

```swift
let pattern = PatternBuilder()
    .text("Project_")
    .date(format: "yyyy-MM-dd")
    .text("_")
    .counter(start: 1, padding: 4)
    .text("_")
    .originalName()
    .build()
```

## Safety Features

1. **Preview Mode**: Always preview changes before executing
2. **Confirmation Required**: Type "YES" to confirm batch operations
3. **Duplicate Detection**: Prevents overwriting existing files
4. **Error Reporting**: Detailed error messages for failed operations
5. **Dry Run Support**: Test operations without making changes

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later
- Xcode 15.0 or later (for building)

## File Structure

```
Bulk-Renaming-Utility/
├── Sources/
│   ├── main.swift           # CLI interface
│   ├── FileRenamer.swift    # Core renaming engine
│   └── NamingPattern.swift  # Pattern system
├── Package.swift            # Swift Package Manager config
└── README.md               # This file
```

## Troubleshooting

### "Directory not found" error
- Ensure the path is correct and accessible
- Use absolute paths or drag & drop folders into the terminal
- Check for proper file permissions

### "Destination file already exists" error
- The target filename already exists
- Modify your pattern to ensure unique names
- Consider adding a counter or random component

### Files not appearing
- Check if files are hidden (use Finder's "Show Hidden Files")
- Ensure you have read permissions for the directory
- Verify files aren't in subdirectories (use recursive option if needed)

## Future Enhancements

- [ ] GUI version with visual preview
- [ ] Recursive directory processing option
- [ ] File filtering by extension or pattern
- [ ] Undo functionality
- [ ] Batch operation history
- [ ] Regular expression support for pattern matching
- [ ] Custom token plugins

## License

MIT License - Feel free to use and modify

## Contributing

Contributions welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Author

Built with Swift for efficient and safe bulk file renaming operations.
