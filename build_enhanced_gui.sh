#!/bin/bash

echo "🎨 Building Enhanced macOS GUI App with File Display..."
echo ""

# Clean up
rm -rf BulkRenamerGUI
rm -rf BulkRenamer.app

# Create project directory
mkdir -p BulkRenamerGUI
cd BulkRenamerGUI

# Copy core files
echo "📋 Copying source files..."
cp ../Sources/FileRenamer.swift .
cp ../Sources/NamingPattern.swift .

# Create main app
cat > AppMain.swift << 'APPCODE'
import SwiftUI

@main
struct BulkRenamerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}
APPCODE

# Create enhanced ContentView with file list
cat > ContentView.swift << 'VIEWCODE'
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedDirectory: URL?
    @State private var pattern: String = "Photo_{counter:1,4}"
    @State private var files: [FileRenamer.FileItem] = []
    @State private var previewOperations: [FileRenamer.RenameOperation] = []
    @State private var showingPreview = false
    @State private var statusMessage = ""
    @State private var statusType: StatusType = .info
    @State private var isProcessing = false

    private let renamer = FileRenamer()

    enum StatusType {
        case success, error, info, warning

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            case .warning: return .orange
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                Text("Bulk File Renamer")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Rename multiple files with powerful patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // Directory Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Select Directory", systemImage: "folder")
                            .font(.headline)

                        HStack {
                            if let dir = selectedDirectory {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.blue)
                                        Text(dir.lastPathComponent)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    Text(dir.path)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Text("📄 \(files.count) file(s)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            } else {
                                Text("No directory selected")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            Button(action: selectDirectory) {
                                Label("Choose Folder", systemImage: "folder.badge.plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Show files when directory is selected (BEFORE preview)
                    if !files.isEmpty && !showingPreview {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Files in Directory (\(files.count))", systemImage: "list.bullet")
                                .font(.headline)

                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(files.prefix(50).enumerated()), id: \.offset) { index, file in
                                        HStack {
                                            Text("\(index + 1).")
                                                .foregroundColor(.secondary)
                                                .frame(width: 40, alignment: .trailing)
                                                .font(.caption.monospacedDigit())

                                            Image(systemName: iconForFile(file))
                                                .foregroundColor(.blue)
                                                .frame(width: 20)

                                            Text(file.originalURL.lastPathComponent)
                                                .font(.caption)
                                                .lineLimit(1)

                                            Spacer()

                                            Text(formatFileSize(file.fileSize))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)

                                        if index < min(49, files.count - 1) {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)

                            if files.count > 50 {
                                Text("... and \(files.count - 50) more files")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Pattern Input
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("Naming Pattern", systemImage: "textformat")
                                .font(.headline)
                            Spacer()
                            Button(action: showPatternHelp) {
                                Label("Help", systemImage: "questionmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }

                        TextField("Enter pattern (e.g., Photo_{counter:1,4})", text: $pattern)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }

                    // Quick Patterns
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Patterns")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                QuickButton(title: "Counter", pattern: "File_{counter:1,3}", current: $pattern)
                                QuickButton(title: "Date + Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                                QuickButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                                QuickButton(title: "Parent Folder", pattern: "{parent}_{counter:1,3}", current: $pattern)
                                QuickButton(title: "Professional", pattern: "{parent}_{date:yyyyMMdd}_{counter:1,4}", current: $pattern)
                            }
                        }
                    }

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: preview) {
                            Label("Preview Changes", systemImage: "eye.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(files.isEmpty || pattern.isEmpty || isProcessing)

                        Button(action: execute) {
                            Label("Rename Files", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.green)
                        .disabled(previewOperations.isEmpty || isProcessing)
                    }

                    // Status Message
                    if !statusMessage.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: statusType.icon)
                                .foregroundColor(statusType.color)
                            Text(statusMessage)
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(statusType.color.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Preview List - Shows OLD → NEW filenames
                    if showingPreview && !previewOperations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Rename Preview (\(previewOperations.count) files)", systemImage: "arrow.left.arrow.right")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    showingPreview = false
                                    previewOperations = []
                                }) {
                                    Label("Clear Preview", systemImage: "xmark.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.borderless)
                            }

                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(previewOperations.prefix(50).enumerated()), id: \.offset) { index, op in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text("\(index + 1).")
                                                    .foregroundColor(.secondary)
                                                    .frame(width: 40, alignment: .trailing)
                                                    .font(.caption.monospacedDigit())

                                                VStack(alignment: .leading, spacing: 4) {
                                                    // OLD filename
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "doc.fill")
                                                            .foregroundColor(.red)
                                                            .font(.caption2)
                                                        Text(op.sourceURL.lastPathComponent)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .strikethrough()
                                                    }

                                                    // Arrow
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "arrow.down")
                                                            .font(.caption2)
                                                            .foregroundColor(.blue)
                                                        Text("")
                                                    }

                                                    // NEW filename
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "doc.badge.plus")
                                                            .foregroundColor(.green)
                                                            .font(.caption2)
                                                        Text(op.newName)
                                                            .font(.caption)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.primary)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)

                                            if index < min(49, previewOperations.count - 1) {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: 300)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)

                            if previewOperations.count > 50 {
                                Text("... and \(previewOperations.count - 50) more files")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 750, minHeight: 700)
    }

    private func iconForFile(_ file: FileRenamer.FileItem) -> String {
        let ext = file.fileExtension.lowercased()
        switch ext {
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo"
        case "mp4", "mov", "avi", "mkv":
            return "film"
        case "mp3", "wav", "aac", "m4a":
            return "music.note"
        case "pdf":
            return "doc.text"
        case "zip", "rar", "7z":
            return "archivebox"
        case "txt", "md":
            return "doc.plaintext"
        default:
            return "doc"
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter.string(fromByteCount: bytes)
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.message = "Choose a folder containing files to rename"

        if panel.runModal() == .OK, let url = panel.url {
            selectedDirectory = url
            loadFiles(from: url)
        }
    }

    private func loadFiles(from directory: URL) {
        isProcessing = true
        statusMessage = "Loading files..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let loadedFiles = try renamer.getFiles(from: directory)
                DispatchQueue.main.async {
                    files = loadedFiles
                    previewOperations = []
                    showingPreview = false

                    if files.isEmpty {
                        statusMessage = "No files found in this directory"
                        statusType = .warning
                    } else {
                        statusMessage = "Loaded \(files.count) file(s) - Enter a pattern and click Preview"
                        statusType = .success
                    }
                    isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "Error loading files: \(error.localizedDescription)"
                    statusType = .error
                    files = []
                    isProcessing = false
                }
            }
        }
    }

    private func preview() {
        guard !files.isEmpty else { return }

        isProcessing = true
        statusMessage = "Generating preview..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            let namingPattern = NamingPattern.from(template: pattern)
            let operations = renamer.previewRename(files: files, pattern: namingPattern)

            DispatchQueue.main.async {
                previewOperations = operations
                showingPreview = true
                statusMessage = "Preview ready - Review \(operations.count) rename operations"
                statusType = .success
                isProcessing = false
            }
        }
    }

    private func execute() {
        guard !previewOperations.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = "Confirm Rename Operation"
        alert.informativeText = "Are you sure you want to rename \(previewOperations.count) file(s)?\n\nThis action cannot be undone!"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Rename Files")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        isProcessing = true
        statusMessage = "Renaming files..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try renamer.executeRename(operations: previewOperations)

                DispatchQueue.main.async {
                    if result.failed.isEmpty {
                        statusMessage = "✅ Successfully renamed \(result.successful) file(s)!"
                        statusType = .success
                    } else {
                        statusMessage = "⚠️ Renamed \(result.successful) file(s), but \(result.failed.count) failed"
                        statusType = .warning
                    }

                    // Reload files from directory
                    if let dir = selectedDirectory {
                        loadFiles(from: dir)
                    }

                    previewOperations = []
                    showingPreview = false
                    isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "Error: \(error.localizedDescription)"
                    statusType = .error
                    isProcessing = false
                }
            }
        }
    }

    private func showPatternHelp() {
        let alert = NSAlert()
        alert.messageText = "Pattern Tokens Reference"
        alert.informativeText = """
        📝 PATTERN TOKENS:

        {counter:start,padding} - Sequential numbers
          Example: {counter:1,3} → 001, 002, 003

        {name} - Original filename (without extension)
        {parent} - Parent folder name
        {date:format} - File modification date
        {created:format} - File creation date
        {size} - File size
        {random:length} - Random string
        {uuid} - Unique identifier

        📅 DATE FORMATS:
        • yyyy-MM-dd → 2025-11-15
        • yyyyMMdd_HHmmss → 20251115_143022
        • MMM-dd-yy → Nov-15-25

        💡 EXAMPLES:
        • Photo_{counter:1,4}
        • {date:yyyy-MM-dd}_{counter:1,3}
        • {parent}_{name}_{counter:1,2}
        • {created:yyyyMMdd}_{counter:100,4}

        Extensions are automatically added!
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Got It!")
        alert.runModal()
    }
}

struct QuickButton: View {
    let title: String
    let pattern: String
    @Binding var current: String

    var body: some View {
        Button(action: { current = pattern }) {
            Text(title)
                .font(.caption)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}
VIEWCODE

echo "📦 Building with Swift 6.2.1..."

# Build
swiftc \
    -target arm64-apple-macosx26.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework SwiftUI \
    -framework AppKit \
    -framework UniformTypeIdentifiers \
    -o BulkRenamer \
    FileRenamer.swift \
    NamingPattern.swift \
    ContentView.swift \
    AppMain.swift

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    cd ..
    exit 1
fi

# Create app bundle
cd ..
APP_NAME="BulkRenamer.app"
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

mv BulkRenamerGUI/BulkRenamer "$APP_NAME/Contents/MacOS/"
chmod +x "$APP_NAME/Contents/MacOS/BulkRenamer"

# Create Info.plist
cat > "$APP_NAME/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BulkRenamer</string>
    <key>CFBundleIdentifier</key>
    <string>com.bulkrenamer.gui</string>
    <key>CFBundleName</key>
    <string>Bulk Renamer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

rm -rf BulkRenamerGUI

echo ""
echo "✅ Enhanced GUI App Created!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo ""
echo "🎨 NEW FEATURES:"
echo "  ✨ Files display immediately when folder is selected"
echo "  👁️ Preview shows: OLD filename → NEW filename"
echo "  📊 File icons and sizes"
echo "  🔄 Auto-reload after rename"
echo ""
echo "🚀 To use: open $APP_NAME"
echo ""
