#!/bin/bash

echo "🔍 Building DEBUG Display Version..."
echo ""

rm -rf BulkRenamerGUI BulkRenamer.app
mkdir -p BulkRenamerGUI && cd BulkRenamerGUI

cp ../Sources/FileRenamer.swift .
cp ../Sources/NamingPattern.swift .

cat > AppMain.swift << 'APPCODE'
import SwiftUI
@main
struct BulkRenamerApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
        .windowStyle(.hiddenTitleBar)
    }
}
APPCODE

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
            headerView
            Divider()
            ScrollView {
                VStack(spacing: 20) {
                    directorySelectionView
                    patternInputView
                    quickPatternsView
                    actionButtonsView
                    if !statusMessage.isEmpty { statusMessageView }
                    twoColumnFileListView
                }
                .padding(20)
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            if let iconPath = Bundle.main.path(forResource: "AppIcon512", ofType: "png"),
               let nsImage = NSImage(contentsOfFile: iconPath) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            Text("Bulk Renaming Utility")
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
                            Image(systemName: "folder.fill").foregroundColor(.blue)
                            Text(dir.lastPathComponent).font(.body).fontWeight(.semibold)
                        }
                        Text(dir.path).font(.caption).foregroundColor(.secondary).lineLimit(1)
                        Text("📄 \(files.count) file(s)").font(.caption).foregroundColor(.blue)
                    }
                    Spacer()
                } else {
                    Text("No directory selected").foregroundColor(.secondary)
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

    private var patternInputView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Naming Pattern", systemImage: "textformat").font(.headline)
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

    private var quickPatternsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Patterns").font(.caption).foregroundColor(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickButton(title: "Counter", pattern: "File_{counter:1,3}", current: $pattern)
                    QuickButton(title: "Date+Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                    QuickButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                    QuickButton(title: "Parent", pattern: "{parent}_{counter:1,3}", current: $pattern)
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
            .controlSize(.large)
            .disabled(files.isEmpty || pattern.isEmpty || isProcessing)

            Button(action: execute) {
                Label("Rename Files", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color(red: 0.2, green: 0.6, blue: 0.2))
            .disabled(previewOperations.isEmpty || isProcessing)
        }
    }

    private var statusMessageView: some View {
        HStack(spacing: 8) {
            Image(systemName: statusType.icon).foregroundColor(statusType.color)
            Text(statusMessage).font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(statusType.color.opacity(0.1))
        .cornerRadius(8)
    }

    private var twoColumnFileListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("File List").font(.headline)
                if !files.isEmpty {
                    Text("(\(files.count) files)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                if !previewOperations.isEmpty {
                    Button(action: clearPreview) {
                        Label("Clear Preview", systemImage: "xmark.circle").font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }

            VStack(spacing: 0) {
                // Headers
                HStack(spacing: 1) {
                    Text("ORIGINAL FILE")
                        .font(.caption).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.blue.opacity(0.8))

                    Text("NEW FILE")
                        .font(.caption).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.2))
                }

                Divider()

                if files.isEmpty {
                    emptyStateView
                } else {
                    // DEBUG: Show file list with minimal styling
                    LazyVStack(spacing: 0) {
                        ForEach(Array(files.enumerated()), id: \.offset) { index, file in
                            HStack(spacing: 10) {
                                // Left column - ORIGINAL
                                Text("\(index + 1). \(file.originalURL.lastPathComponent)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))

                                // Right column - NEW
                                if let newName = newNameForFile(at: index) {
                                    Text(newName)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(Color.green.opacity(0.1))
                                } else {
                                    Text("—")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.05))
                                }
                            }
                            .border(Color.gray.opacity(0.2))
                        }
                    }
                    .frame(minHeight: 200, maxHeight: 400)
                }
            }
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No folder selected").foregroundColor(.secondary)
            Text("Click 'Choose Folder' to get started").font(.caption).foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }

    private func newNameForFile(at index: Int) -> String? {
        print("🔍 DEBUG newNameForFile: index=\(index), previewOps.count=\(previewOperations.count)")
        guard !previewOperations.isEmpty, index < previewOperations.count else { return nil }
        let newName = previewOperations[index].newName
        print("  → returning: \(newName)")
        return newName
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"

        panel.begin { response in
            print("🔍 DEBUG Panel response: \(response)")
            if response == .OK, let url = panel.url {
                print("🔍 DEBUG Selected URL: \(url.path)")
                self.selectedDirectory = url
                self.loadFiles(from: url)
            }
        }
    }

    private func loadFiles(from directory: URL) {
        print("🔍 DEBUG loadFiles START: \(directory.path)")
        files = []
        previewOperations = []
        isProcessing = true
        statusMessage = "Loading..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let gotAccess = directory.startAccessingSecurityScopedResource()
                defer { if gotAccess { directory.stopAccessingSecurityScopedResource() } }

                print("🔍 DEBUG Calling renamer.getFiles...")
                let loadedFiles = try renamer.getFiles(from: directory)
                print("🔍 DEBUG Got \(loadedFiles.count) files")

                for (i, f) in loadedFiles.enumerated() {
                    print("  [\(i)] \(f.originalURL.lastPathComponent)")
                }

                DispatchQueue.main.async {
                    print("🔍 DEBUG Setting files array to \(loadedFiles.count) items")
                    self.files = loadedFiles
                    print("🔍 DEBUG self.files now has \(self.files.count) items")

                    if loadedFiles.isEmpty {
                        self.statusMessage = "No files found"
                        self.statusType = .warning
                    } else {
                        self.statusMessage = "✅ Loaded \(loadedFiles.count) files"
                        self.statusType = .success
                    }
                    self.isProcessing = false

                    print("🔍 DEBUG loadFiles COMPLETE - UI should update")
                }
            } catch {
                print("🔍 DEBUG ERROR: \(error)")
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
        print("🔍 DEBUG preview START - files.count=\(files.count)")
        guard !files.isEmpty else { return }
        isProcessing = true
        statusMessage = "Generating preview..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            let namingPattern = NamingPattern.from(template: pattern)
            let operations = renamer.previewRename(files: files, pattern: namingPattern)

            print("🔍 DEBUG Preview generated \(operations.count) operations")
            for (i, op) in operations.enumerated() {
                print("  [\(i)] '\(op.sourceURL.lastPathComponent)' → '\(op.newName)'")
            }

            DispatchQueue.main.async {
                print("🔍 DEBUG Setting previewOperations to \(operations.count) items")
                self.previewOperations = operations
                print("🔍 DEBUG self.previewOperations now has \(self.previewOperations.count) items")
                self.statusMessage = "👁️ Preview ready - \(operations.count) operations"
                self.statusType = .success
                self.isProcessing = false
                print("🔍 DEBUG preview COMPLETE - UI should update")
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
        alert.informativeText = "Rename \(previewOperations.count) files?\n\nCannot be undone!"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        isProcessing = true
        statusMessage = "Renaming..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try renamer.executeRename(operations: previewOperations)
                DispatchQueue.main.async {
                    if result.failed.isEmpty {
                        self.statusMessage = "✅ Renamed \(result.successful) files!"
                        self.statusType = .success
                    } else {
                        self.statusMessage = "⚠️ Renamed \(result.successful), failed \(result.failed.count)"
                        self.statusType = .warning
                    }
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
        {counter:1,3} - Numbers
        {name} - Original filename
        {date:yyyy-MM-dd} - Date
        {parent} - Folder name
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
        Button(title) { current = pattern }
            .buttonStyle(.bordered)
            .controlSize(.small)
    }
}
VIEWCODE

echo "📦 Compiling DEBUG version..."

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

cd ..
APP_NAME="BulkRenamer.app"
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS" "$APP_NAME/Contents/Resources"

mv BulkRenamerGUI/BulkRenamer "$APP_NAME/Contents/MacOS/"
chmod +x "$APP_NAME/Contents/MacOS/BulkRenamer"

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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# Copy app icon files to Resources
if [ -f AppIcon.icns ]; then
    cp AppIcon.icns "$APP_NAME/Contents/Resources/"
    echo "✅ Copied AppIcon.icns to app bundle"
fi

if [ -f AppIcon512.png ]; then
    cp AppIcon512.png "$APP_NAME/Contents/Resources/"
    echo "✅ Copied AppIcon512.png to app bundle"
fi

rm -rf BulkRenamerGUI
xattr -cr "$APP_NAME"

echo ""
echo "✅ DEBUG Version Complete!"
echo ""
echo "🔍 This version has:"
echo "  - Extensive console logging (print statements)"
echo "  - Simplified layout with visible backgrounds"
echo "  - Border around each row"
echo "  - LazyVStack instead of ScrollView"
echo ""
echo "📋 To see logs:"
echo "  1. Open Console.app"
echo "  2. Filter for 'BulkRenamer'"
echo "  3. Run: open $APP_NAME"
echo ""
echo "🚀 Launch: open $APP_NAME"
echo ""
