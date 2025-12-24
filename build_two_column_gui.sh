#!/bin/bash

echo "🎨 Building Two-Column GUI App..."
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

# Create two-column ContentView
cat > ContentView.swift << 'VIEWCODE'
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedDirectory: URL?
    @State private var pattern: String = "Photo_{counter:1,4}"
    @State private var files: [FileRenamer.FileItem] = []
    @State private var previewOperations: [FileRenamer.RenameOperation] = []
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
            headerView

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // Directory Selection
                    directorySelectionView

                    // Pattern Input
                    patternInputView

                    // Quick Patterns
                    quickPatternsView

                    // Action Buttons
                    actionButtonsView

                    // Status Message
                    if !statusMessage.isEmpty {
                        statusMessageView
                    }

                    // TWO-COLUMN FILE LIST BOX
                    twoColumnFileListView
                }
                .padding(20)
            }
        }
        .frame(minWidth: 900, minHeight: 700)
    }

    // MARK: - Header

    private var headerView: some View {
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
    }

    // MARK: - Directory Selection

    private var directorySelectionView: some View {
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
    }

    // MARK: - Pattern Input

    private var patternInputView: some View {
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

            TextField("Photo_{counter:1,4}", text: $pattern)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
        }
    }

    // MARK: - Quick Patterns

    private var quickPatternsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Patterns")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickButton(title: "Counter", pattern: "File_{counter:1,3}", current: $pattern)
                    QuickButton(title: "Date+Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                    QuickButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                    QuickButton(title: "Parent", pattern: "{parent}_{counter:1,3}", current: $pattern)
                    QuickButton(title: "Professional", pattern: "{parent}_{date:yyyyMMdd}_{counter:1,4}", current: $pattern)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsView: some View {
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
    }

    // MARK: - Status Message

    private var statusMessageView: some View {
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

    // MARK: - Two-Column File List

    private var twoColumnFileListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("File List")
                    .font(.headline)
                if !files.isEmpty {
                    Text("(\(files.count) files)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if !previewOperations.isEmpty {
                    Button(action: clearPreview) {
                        Label("Clear Preview", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }

            // Two-Column Box
            VStack(spacing: 0) {
                // Column Headers
                HStack(spacing: 0) {
                    // Original File Column Header
                    Text("ORIGINAL FILE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.blue)

                    Divider()
                        .background(Color.white)

                    // New File Column Header
                    Text("NEW FILE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.green)
                }

                Divider()

                // File Rows
                if files.isEmpty {
                    // Empty state
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No folder selected")
                                .foregroundColor(.secondary)
                            Text("Click 'Choose Folder' to get started")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(files.enumerated()), id: \.offset) { index, file in
                                HStack(spacing: 0) {
                                    // Original File Column
                                    HStack(spacing: 4) {
                                        Text("\(index + 1).")
                                            .foregroundColor(.secondary)
                                            .frame(width: 35, alignment: .trailing)
                                            .font(.caption.monospacedDigit())

                                        Image(systemName: iconForFile(file))
                                            .foregroundColor(.blue)
                                            .frame(width: 20)

                                        Text(file.originalURL.lastPathComponent)
                                            .font(.caption)
                                            .lineLimit(1)

                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))

                                    Divider()

                                    // New File Column
                                    HStack(spacing: 4) {
                                        if let newName = newNameForFile(at: index) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .frame(width: 20)

                                            Text(newName)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                        } else {
                                            Text("—")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }

                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                                }

                                if index < files.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(height: 350)
                }
            }
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helper Functions

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

    private func newNameForFile(at index: Int) -> String? {
        guard !previewOperations.isEmpty, index < previewOperations.count else {
            return nil
        }
        return previewOperations[index].newName
    }

    // MARK: - Actions

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.message = "Choose a folder with files to rename"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.selectedDirectory = url
                self.loadFiles(from: url)
            }
        }
    }

    private func loadFiles(from directory: URL) {
        print("📂 Loading files from: \(directory.path)")

        files = []
        previewOperations = []
        isProcessing = true
        statusMessage = "Loading files..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let gotAccess = directory.startAccessingSecurityScopedResource()
                defer {
                    if gotAccess {
                        directory.stopAccessingSecurityScopedResource()
                    }
                }

                let loadedFiles = try renamer.getFiles(from: directory)
                print("✅ Loaded \(loadedFiles.count) files")

                DispatchQueue.main.async {
                    self.files = loadedFiles

                    if loadedFiles.isEmpty {
                        self.statusMessage = "No files found in this directory"
                        self.statusType = .warning
                    } else {
                        self.statusMessage = "✅ Loaded \(loadedFiles.count) file(s) - Enter pattern and click Preview"
                        self.statusType = .success
                    }
                    self.isProcessing = false
                }
            } catch {
                print("❌ Error: \(error)")
                DispatchQueue.main.async {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.statusType = .error
                    self.files = []
                    self.isProcessing = false
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

            print("👁️ Generated \(operations.count) preview operations")

            DispatchQueue.main.async {
                self.previewOperations = operations
                self.statusMessage = "👁️ Preview ready - New filenames shown in right column"
                self.statusType = .success
                self.isProcessing = false
            }
        }
    }

    private func clearPreview() {
        previewOperations = []
        statusMessage = "Preview cleared"
        statusType = .info
    }

    private func execute() {
        guard !previewOperations.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = "Confirm Rename"
        alert.informativeText = "Rename \(previewOperations.count) files?\n\nThis cannot be undone!"
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
                        self.statusMessage = "✅ Successfully renamed \(result.successful) files!"
                        self.statusType = .success
                    } else {
                        self.statusMessage = "⚠️ Renamed \(result.successful), failed \(result.failed.count)"
                        self.statusType = .warning
                    }

                    // Reload files
                    if let dir = self.selectedDirectory {
                        self.loadFiles(from: dir)
                    }

                    self.previewOperations = []
                    self.isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.statusType = .error
                    self.isProcessing = false
                }
            }
        }
    }

    private func showPatternHelp() {
        let alert = NSAlert()
        alert.messageText = "Pattern Tokens"
        alert.informativeText = """
        {counter:1,3} - Sequential numbers (001, 002)
        {name} - Original filename
        {date:yyyy-MM-dd} - File date
        {parent} - Folder name
        {random:6} - Random string

        Examples:
        • Photo_{counter:1,4}
        • {date:yyyy-MM-dd}_{counter:1,3}
        • {parent}_{name}_{counter:1,2}
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct QuickButton: View {
    let title: String
    let pattern: String
    @Binding var current: String

    var body: some View {
        Button(title) {
            current = pattern
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}
VIEWCODE

echo "📦 Compiling..."

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
xattr -cr "$APP_NAME"

echo ""
echo "✅ Two-Column GUI App Created!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo ""
echo "🎨 NEW LAYOUT:"
echo "  ┌─────────────────────────────────────┐"
echo "  │ ORIGINAL FILE  │  NEW FILE          │"
echo "  ├────────────────┼────────────────────┤"
echo "  │ photo1.jpg     │  —                 │"
echo "  │ photo2.jpg     │  —                 │"
echo "  └────────────────┴────────────────────┘"
echo ""
echo "  After Preview:"
echo "  ┌─────────────────────────────────────┐"
echo "  │ ORIGINAL FILE  │  NEW FILE          │"
echo "  ├────────────────┼────────────────────┤"
echo "  │ photo1.jpg     │  Photo_001.jpg     │"
echo "  │ photo2.jpg     │  Photo_002.jpg     │"
echo "  └────────────────┴────────────────────┘"
echo ""
echo "🚀 To use: open $APP_NAME"
echo ""
