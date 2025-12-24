#!/bin/bash

echo "🎨 Building Native macOS GUI App with Xcode Beta (macOS 26.2)..."
echo ""

# Clean up old builds
rm -rf BulkRenamerGUI
rm -rf BulkRenamer.app

# Create project directory
mkdir -p BulkRenamerGUI
cd BulkRenamerGUI

# Copy core source files
echo "📋 Copying source files..."
cp ../Sources/FileRenamer.swift .
cp ../Sources/NamingPattern.swift .

# Create main SwiftUI app file (without Preview macro)
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

# Create ContentView without Preview
cat > ContentView.swift << 'VIEWCODE'
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedDirectory: URL?
    @State private var pattern: String = "Photo_{counter:1,4}"
    @State private var previewOperations: [FileRenamer.RenameOperation] = []
    @State private var showingPreview = false
    @State private var statusMessage = ""
    @State private var statusType: StatusType = .info
    @State private var isProcessing = false
    @State private var showingFolderPicker = false

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
                                    if let count = fileCount {
                                        Text(count)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                Spacer()
                            } else {
                                Text("No directory selected")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            Button(action: selectDirectory) {
                                Label("Choose", systemImage: "folder.badge.plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Pattern Input
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("Pattern", systemImage: "textformat")
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
                            }
                        }
                    }

                    // Buttons
                    HStack(spacing: 12) {
                        Button(action: preview) {
                            Label("Preview", systemImage: "eye.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedDirectory == nil || pattern.isEmpty || isProcessing)

                        Button(action: execute) {
                            Label("Rename", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(selectedDirectory == nil || previewOperations.isEmpty || isProcessing)
                    }
                    .controlSize(.large)

                    // Status
                    if !statusMessage.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: statusType.icon)
                                .foregroundColor(statusType.color)
                            Text(statusMessage)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(statusType.color.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Preview
                    if showingPreview && !previewOperations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Preview (\(previewOperations.count) files)", systemImage: "list.bullet")
                                    .font(.headline)
                                Spacer()
                            }

                            VStack(spacing: 0) {
                                ForEach(Array(previewOperations.prefix(20).enumerated()), id: \.offset) { index, op in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("\(index + 1).")
                                                .foregroundColor(.secondary)
                                                .frame(width: 40, alignment: .trailing)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(op.sourceURL.lastPathComponent)
                                                    .strikethrough()
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.right")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                    Text(op.newName)
                                                        .fontWeight(.semibold)
                                                        .font(.caption)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        if index < 19 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                            if previewOperations.count > 20 {
                                Text("... and \(previewOperations.count - 20) more")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 700, minHeight: 600)
    }

    private var fileCount: String? {
        guard let dir = selectedDirectory else { return nil }
        if let files = try? renamer.getFiles(from: dir) {
            return "📄 \(files.count) files"
        }
        return nil
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            selectedDirectory = url
            statusMessage = ""
            previewOperations = []
            showingPreview = false
        }
    }

    private func preview() {
        guard let directory = selectedDirectory else { return }
        isProcessing = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let files = try renamer.getFiles(from: directory)
                DispatchQueue.main.async {
                    if files.isEmpty {
                        statusMessage = "No files found"
                        statusType = .warning
                        isProcessing = false
                        return
                    }
                    let namingPattern = NamingPattern.from(template: pattern)
                    previewOperations = renamer.previewRename(files: files, pattern: namingPattern)
                    showingPreview = true
                    statusMessage = "Preview ready - \(previewOperations.count) files"
                    statusType = .success
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

    private func execute() {
        let alert = NSAlert()
        alert.messageText = "Confirm Rename"
        alert.informativeText = "Rename \(previewOperations.count) files? Cannot be undone!"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try renamer.executeRename(operations: previewOperations)
                DispatchQueue.main.async {
                    statusMessage = "✅ Renamed \(result.successful) files"
                    statusType = .success
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
        {counter:1,3} - Sequential numbers
        {name} - Original filename
        {date:yyyy-MM-dd} - Date
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

echo "📦 Building with Swift 6.2.1..."

# Build the app
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

# Move executable
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

# Cleanup
rm -rf BulkRenamerGUI

echo ""
echo "✅ Native macOS GUI App Created!"
echo ""
echo "📍 Location: $(pwd)/$APP_NAME"
echo ""
echo "🚀 To use:"
echo "  • Double-click $APP_NAME"
echo "  • Or run: open $APP_NAME"
echo ""
echo "This is a REAL GUI app with:"
echo "  ✨ Native macOS window"
echo "  🎯 Folder picker dialog"
echo "  👁️ Visual preview"
echo "  🖱️ Click buttons"
echo ""
