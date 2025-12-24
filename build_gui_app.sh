#!/bin/bash

echo "🔨 Building Native macOS GUI Application..."

# Create temporary Xcode project structure
PROJECT_NAME="BulkRenamerGUI"
APP_NAME="BulkRenamer"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Copy source files
echo "📋 Copying source files..."
cp ../Sources/FileRenamer.swift .
cp ../Sources/NamingPattern.swift .
cp ../BulkRenamerApp.swift .

# Create proper SwiftUI app with @main
cat > BulkRenamerMain.swift << 'APPCODE'
import SwiftUI
import AppKit

@main
struct BulkRenamerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
APPCODE

# Create the SwiftUI ContentView
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

                    // Quick Pattern Buttons
                    quickPatternsView

                    // Action Buttons
                    actionButtonsView

                    // Status Message
                    if !statusMessage.isEmpty {
                        statusMessageView
                    }

                    // Preview List
                    if showingPreview && !previewOperations.isEmpty {
                        previewListView
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 700, minHeight: 600)
    }

    // MARK: - View Components

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
                            .truncationMode(.middle)
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
                    Label("Choose Folder", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }

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

            TextField("Enter naming pattern (e.g., Photo_{counter:1,4})", text: $pattern)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
        }
    }

    private var quickPatternsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Patterns")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickPatternButton(title: "Counter", pattern: "File_{counter:1,3}", current: $pattern)
                    QuickPatternButton(title: "Date + Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                    QuickPatternButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                    QuickPatternButton(title: "Parent Folder", pattern: "{parent}_{counter:1,3}", current: $pattern)
                    QuickPatternButton(title: "With Date", pattern: "{parent}_{date:yyyyMMdd}_{counter:1,4}", current: $pattern)
                }
            }
        }
    }

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            Button(action: preview) {
                Label("Preview Changes", systemImage: "eye.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(selectedDirectory == nil || pattern.isEmpty || isProcessing)

            Button(action: execute) {
                Label("Rename Files", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(selectedDirectory == nil || pattern.isEmpty || previewOperations.isEmpty || isProcessing)
        }
        .controlSize(.large)
    }

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

    private var previewListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Preview (\(previewOperations.count) files)", systemImage: "list.bullet")
                    .font(.headline)
                Spacer()
                if previewOperations.count > 20 {
                    Text("Showing first 20")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(previewOperations.prefix(20).enumerated()), id: \.offset) { index, operation in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .trailing)
                                .font(.caption.monospacedDigit())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(operation.sourceURL.lastPathComponent)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                                    .font(.caption)

                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.right")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text(operation.newName)
                                        .fontWeight(.semibold)
                                        .font(.caption)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)

                        if index < min(19, previewOperations.count - 1) {
                            Divider()
                        }
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            if previewOperations.count > 20 {
                Text("... and \(previewOperations.count - 20) more files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var fileCount: String? {
        guard let dir = selectedDirectory else { return nil }
        if let files = try? renamer.getFiles(from: dir) {
            return "📄 \(files.count) file(s) found"
        }
        return nil
    }

    // MARK: - Actions

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.message = "Choose a folder containing files to rename"

        if panel.runModal() == .OK, let url = panel.url {
            selectedDirectory = url
            statusMessage = ""
            previewOperations = []
            showingPreview = false
            statusType = .info
        }
    }

    private func preview() {
        guard let directory = selectedDirectory else { return }

        isProcessing = true
        statusMessage = "Loading files..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let files = try renamer.getFiles(from: directory)

                DispatchQueue.main.async {
                    if files.isEmpty {
                        statusMessage = "No files found in this directory"
                        statusType = .warning
                        isProcessing = false
                        return
                    }

                    let namingPattern = NamingPattern.from(template: pattern)
                    previewOperations = renamer.previewRename(files: files, pattern: namingPattern)
                    showingPreview = true
                    statusMessage = "Preview ready - \(previewOperations.count) file(s) will be renamed"
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

struct QuickPatternButton: View {
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

#Preview {
    ContentView()
        .frame(width: 700, height: 600)
}
VIEWCODE

echo "📦 Building macOS app..."

# Build with swiftc
swiftc -o BulkRenamer \
    -target arm64-apple-macos13.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework SwiftUI \
    -framework AppKit \
    -framework UniformTypeIdentifiers \
    FileRenamer.swift \
    NamingPattern.swift \
    ContentView.swift \
    BulkRenamerMain.swift

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    cd ..
    exit 1
fi

# Create app bundle
APP_PATH="../${APP_NAME}.app"
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Move executable
mv BulkRenamer "$APP_PATH/Contents/MacOS/"
chmod +x "$APP_PATH/Contents/MacOS/BulkRenamer"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>BulkRenamer</string>
    <key>CFBundleIdentifier</key>
    <string>com.bulkrenamer.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Bulk Renamer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
PLIST

# Cleanup
cd ..
rm -rf "$PROJECT_NAME"

echo "✅ Native macOS GUI app created successfully!"
echo ""
echo "📍 Location: $(pwd)/${APP_NAME}.app"
echo ""
echo "🚀 To use:"
echo "  • Double-click ${APP_NAME}.app"
echo "  • Or run: open ${APP_NAME}.app"
echo "  • Or drag to /Applications"
echo ""
