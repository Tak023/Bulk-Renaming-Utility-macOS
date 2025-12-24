#!/bin/bash

echo "🔨 Building GUI App with Full Disk Access..."
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

# Create enhanced ContentView with better error handling
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

                    // Show files when directory is selected
                    if !files.isEmpty && !showingPreview {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Files in Directory (\(files.count))", systemImage: "list.bullet")
                                .font(.headline)

                            ScrollView {
                                VStack(spacing: 2) {
                                    ForEach(Array(files.prefix(100).enumerated()), id: \.offset) { index, file in
                                        HStack(spacing: 8) {
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
                                                .frame(width: 60, alignment: .trailing)
                                        }
                                        .padding(.vertical, 3)
                                        .padding(.horizontal, 8)
                                        .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                                    }
                                }
                            }
                            .frame(height: 250)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )

                            if files.count > 100 {
                                Text("Showing first 100 of \(files.count) files")
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

                        TextField("Photo_{counter:1,4}", text: $pattern)
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
                                QuickButton(title: "Date+Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                                QuickButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                                QuickButton(title: "Parent", pattern: "{parent}_{counter:1,3}", current: $pattern)
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

                    // Status
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

                    // Preview with OLD → NEW
                    if showingPreview && !previewOperations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Rename Preview (\(previewOperations.count) files)", systemImage: "arrow.left.arrow.right")
                                    .font(.headline)
                                Spacer()
                                Button(action: clearPreview) {
                                    Label("Clear", systemImage: "xmark.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.borderless)
                            }

                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(previewOperations.prefix(100).enumerated()), id: \.offset) { index, op in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(spacing: 8) {
                                                Text("\(index + 1).")
                                                    .foregroundColor(.secondary)
                                                    .frame(width: 40, alignment: .trailing)
                                                    .font(.caption.monospacedDigit())

                                                VStack(alignment: .leading, spacing: 3) {
                                                    // OLD
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.red)
                                                            .font(.caption2)
                                                        Text(op.sourceURL.lastPathComponent)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .strikethrough()
                                                    }

                                                    // Arrow
                                                    Image(systemName: "arrow.down")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                        .padding(.leading, 4)

                                                    // NEW
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                            .font(.caption2)
                                                        Text(op.newName)
                                                            .font(.caption)
                                                            .fontWeight(.semibold)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                                        }
                                    }
                                }
                            }
                            .frame(height: 300)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )

                            if previewOperations.count > 100 {
                                Text("Showing first 100 of \(previewOperations.count) files")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 800, minHeight: 750)
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
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.message = "Choose a folder with files to rename"
        panel.canCreateDirectories = false

        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.selectedDirectory = url
                self.loadFiles(from: url)
            }
        }
    }

    private func loadFiles(from directory: URL) {
        print("Loading files from: \(directory.path)")

        files = []
        previewOperations = []
        showingPreview = false
        isProcessing = true
        statusMessage = "Loading files..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Start accessing security-scoped resource
                let gotAccess = directory.startAccessingSecurityScopedResource()
                defer {
                    if gotAccess {
                        directory.stopAccessingSecurityScopedResource()
                    }
                }

                let loadedFiles = try renamer.getFiles(from: directory)
                print("Loaded \(loadedFiles.count) files")

                DispatchQueue.main.async {
                    self.files = loadedFiles

                    if loadedFiles.isEmpty {
                        self.statusMessage = "No files found in this directory"
                        self.statusType = .warning
                    } else {
                        self.statusMessage = "✅ Loaded \(loadedFiles.count) file(s)"
                        self.statusType = .success
                    }
                    self.isProcessing = false
                }
            } catch {
                print("Error loading files: \(error)")
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

            DispatchQueue.main.async {
                previewOperations = operations
                showingPreview = true
                statusMessage = "👁️ Preview ready - \(operations.count) rename operations"
                statusType = .success
                isProcessing = false
            }
        }
    }

    private func clearPreview() {
        showingPreview = false
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
                        statusMessage = "✅ Renamed \(result.successful) files!"
                        statusType = .success
                    } else {
                        statusMessage = "⚠️ Renamed \(result.successful), failed \(result.failed.count)"
                        statusType = .warning
                    }

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
        alert.messageText = "Pattern Tokens"
        alert.informativeText = """
        {counter:1,3} - Numbers (001, 002)
        {name} - Original filename
        {date:yyyy-MM-dd} - Date
        {parent} - Folder name
        {random:6} - Random text

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

# Create Info.plist with file access entitlements
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
    <key>NSUserDirectoryUsageDescription</key>
    <string>Bulk Renamer needs access to rename files in the selected directory.</string>
</dict>
</plist>
PLIST

# Cleanup
rm -rf BulkRenamerGUI

# Remove quarantine
xattr -cr "$APP_NAME"

echo ""
echo "✅ App Built with File Access!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo ""
echo "🚀 Testing: open $APP_NAME"
echo ""
echo "✨ FEATURES:"
echo "  • Files display immediately when folder selected"
echo "  • Clear OLD → NEW preview"
echo "  • Security-scoped file access"
echo "  • Better error handling"
echo ""
