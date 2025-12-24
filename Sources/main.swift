import Foundation

/// Command-line interface for the bulk renaming utility
class BulkRenamerCLI {
    private let renamer = FileRenamer()
    private var selectedDirectory: URL?

    func run() {
        printWelcome()

        while true {
            printMenu()
            guard let choice = readChoice() else { continue }

            switch choice {
            case 1:
                selectDirectory()
            case 2:
                previewRename()
            case 3:
                executeRename()
            case 4:
                showExamples()
            case 5:
                showPatternHelp()
            case 0:
                print("\nGoodbye!")
                return
            default:
                print("Invalid choice. Please try again.")
            }
        }
    }

    private func printWelcome() {
        print("""
        ╔═══════════════════════════════════════════════════════╗
        ║      BULK FILE RENAMING UTILITY                       ║
        ║      Version 1.0                                      ║
        ╚═══════════════════════════════════════════════════════╝
        """)
    }

    private func printMenu() {
        print("\n" + String(repeating: "─", count: 55))
        if let dir = selectedDirectory {
            print("📁 Current Directory: \(dir.path)")
        } else {
            print("📁 No directory selected")
        }
        print(String(repeating: "─", count: 55))
        print("""
        1. Select Directory
        2. Preview Rename Operations
        3. Execute Rename
        4. Show Examples
        5. Show Pattern Help
        0. Exit
        """)
        print(String(repeating: "─", count: 55))
        print("Enter your choice: ", terminator: "")
    }

    private func readChoice() -> Int? {
        guard let input = readLine(), let choice = Int(input) else {
            return nil
        }
        return choice
    }

    private func selectDirectory() {
        print("\nEnter directory path (or drag & drop a folder): ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
            return
        }

        // Clean up the path (remove quotes if present)
        let cleanPath = input.replacingOccurrences(of: "\"", with: "")
                             .replacingOccurrences(of: "'", with: "")

        let url = URL(fileURLWithPath: cleanPath)

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
           isDirectory.boolValue {
            selectedDirectory = url
            print("✅ Directory selected: \(url.path)")

            // Show file count
            if let files = try? renamer.getFiles(from: url) {
                print("📄 Found \(files.count) file(s)")
            }
        } else {
            print("❌ Invalid directory path")
        }
    }

    private func previewRename() {
        guard let directory = selectedDirectory else {
            print("❌ Please select a directory first")
            return
        }

        print("\nEnter naming pattern (or type 'help' for assistance): ", terminator: "")
        guard let patternString = readLine()?.trimmingCharacters(in: .whitespaces) else {
            return
        }

        if patternString.lowercased() == "help" {
            showPatternHelp()
            return
        }

        do {
            let files = try renamer.getFiles(from: directory)

            if files.isEmpty {
                print("⚠️  No files found in directory")
                return
            }

            let pattern = NamingPattern.from(template: patternString)
            let operations = renamer.previewRename(files: files, pattern: pattern)

            print("\n" + String(repeating: "═", count: 80))
            print("PREVIEW: \(operations.count) file(s) will be renamed")
            print(String(repeating: "═", count: 80))

            for (index, op) in operations.prefix(20).enumerated() {
                let status = op.isValid ? "✓" : "✗"
                print("\(status) \(index + 1). \(op.sourceURL.lastPathComponent)")
                print("   → \(op.newName)")
            }

            if operations.count > 20 {
                print("\n... and \(operations.count - 20) more file(s)")
            }

            print(String(repeating: "═", count: 80))
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }

    private func executeRename() {
        guard let directory = selectedDirectory else {
            print("❌ Please select a directory first")
            return
        }

        print("\nEnter naming pattern: ", terminator: "")
        guard let patternString = readLine()?.trimmingCharacters(in: .whitespaces) else {
            return
        }

        do {
            let files = try renamer.getFiles(from: directory)

            if files.isEmpty {
                print("⚠️  No files found in directory")
                return
            }

            let pattern = NamingPattern.from(template: patternString)
            let operations = renamer.previewRename(files: files, pattern: pattern)

            print("\n⚠️  You are about to rename \(operations.count) file(s)")
            print("Type 'YES' to confirm: ", terminator: "")

            guard let confirmation = readLine()?.trimmingCharacters(in: .whitespaces),
                  confirmation == "YES" else {
                print("❌ Operation cancelled")
                return
            }

            let result = try renamer.executeRename(operations: operations)

            print("\n" + String(repeating: "═", count: 80))
            print("✅ Successfully renamed: \(result.successful) file(s)")

            if !result.failed.isEmpty {
                print("❌ Failed to rename: \(result.failed.count) file(s)")
                for (op, error) in result.failed {
                    print("   • \(op.sourceURL.lastPathComponent): \(error.localizedDescription)")
                }
            }
            print(String(repeating: "═", count: 80))

        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }

    private func showExamples() {
        print("""

        ╔═══════════════════════════════════════════════════════════════════╗
        ║                    NAMING PATTERN EXAMPLES                        ║
        ╚═══════════════════════════════════════════════════════════════════╝

        📝 Simple Counter:
           Pattern: Photo_{counter:1,4}
           Result:  Photo_0001.jpg, Photo_0002.jpg, Photo_0003.jpg

        📅 Date-based:
           Pattern: {date:yyyy-MM-dd}_{counter:1,3}
           Result:  2025-11-15_001.jpg, 2025-11-15_002.jpg

        🔤 Text Transformations:
           Pattern: {upper:prefix}_{counter:1,3}_{lower:suffix}
           Result:  PREFIX_001_suffix.jpg, PREFIX_002_suffix.jpg

        📁 Parent Folder + Counter:
           Pattern: {parent}_{counter:1,3}
           Result:  ProjectName_001.jpg, ProjectName_002.jpg

        🎲 Random Identifier:
           Pattern: file_{random:6}_{counter:1,2}
           Result:  file_aB3xY9_01.jpg, file_kL8mN2_02.jpg

        🆔 UUID:
           Pattern: {uuid}
           Result:  A1B2C3D4-E5F6-7890-ABCD-EF1234567890.jpg

        📊 With File Size:
           Pattern: {name}_{size}
           Result:  photo_2.5MB.jpg, document_156KB.pdf

        🎨 Complex Example:
           Pattern: {date:yyyyMMdd}_{parent}_{counter:100,4}_{upper:name}
           Result:  20251115_Photos_0100_VACATION.jpg

        """)
    }

    private func showPatternHelp() {
        print("""

        ╔═══════════════════════════════════════════════════════════════════╗
        ║                    PATTERN TOKENS REFERENCE                       ║
        ╚═══════════════════════════════════════════════════════════════════╝

        🔢 COUNTERS:
           {counter:start,padding}  - Sequential number
              Examples: {counter:1,3} → 001, 002, 003
                       {counter:100,4} → 0100, 0101, 0102

        📝 FILE INFORMATION:
           {name} or {original}    - Original filename (without extension)
           {ext} or {extension}    - File extension
           {parent}                - Parent folder name
           {size}                  - File size (human-readable)

        📅 DATES:
           {date:format}           - Modification date
           {created:format}        - Creation date
              Format examples:
                yyyy-MM-dd          → 2025-11-15
                yyyyMMdd_HHmmss     → 20251115_143022
                MMM-dd-yy           → Nov-15-25

        🔤 TEXT TRANSFORMS:
           {upper:text} or {uppercase:text}   - UPPERCASE
           {lower:text} or {lowercase:text}   - lowercase
           {capitalize:text} or {title:text}  - Capitalized

        🎲 RANDOM & UNIQUE:
           {random:length}         - Random alphanumeric string
           {uuid}                  - Unique UUID

        💡 TIPS:
           • Combine multiple tokens: {date:yyyy-MM-dd}_{counter:1,3}
           • Plain text is allowed: MyFile_{counter:1,3}
           • Extensions are added automatically
           • Use colons (:) for parameters, commas (,) to separate them

        """)
    }
}

// Run the CLI
let cli = BulkRenamerCLI()
cli.run()
