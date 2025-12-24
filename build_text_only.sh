#!/bin/bash

echo "📝 Building Text-Only Two-Column GUI (NO ICONS)..."
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
                    fileListView
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

    private var fileListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(files.enumerated()), id: \.offset) { index, file in
                    FileRowView(
                        index: index,
                        fileName: file.originalURL.lastPathComponent,
                        newName: newNameForFile(at: index)
                    )
                    if index < files.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .frame(height: 350)
    }

    private func newNameForFile(at index: Int) -> String? {
        guard !previewOperations.isEmpty, index < previewOperations.count else { return nil }
        return previewOperations[index].newName
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.selectedDirectory = url
                self.loadFiles(from: url)
            }
        }
    }

    private func loadFiles(from directory: URL) {
        print("📂 Loading: \(directory.path)")
        files = []
        previewOperations = []
        isProcessing = true
        statusMessage = "Loading..."
        statusType = .info

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let gotAccess = directory.startAccessingSecurityScopedResource()
                defer { if gotAccess { directory.stopAccessingSecurityScopedResource() } }

                let loadedFiles = try renamer.getFiles(from: directory)
                print("✅ Loaded \(loadedFiles.count) files")
                for (i, f) in loadedFiles.prefix(3).enumerated() {
                    print("  \(i+1). \(f.originalURL.lastPathComponent)")
                }

                DispatchQueue.main.async {
                    self.files = loadedFiles
                    if loadedFiles.isEmpty {
                        self.statusMessage = "No files found"
                        self.statusType = .warning
                    } else {
                        self.statusMessage = "✅ Loaded \(loadedFiles.count) files"
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

            print("👁️ Preview: \(operations.count) operations")
            for (i, op) in operations.prefix(3).enumerated() {
                print("  \(i+1). '\(op.sourceURL.lastPathComponent)' → '\(op.newName)'")
            }

            DispatchQueue.main.async {
                self.previewOperations = operations
                self.statusMessage = "👁️ Preview ready"
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

struct FileRowView: View {
    let index: Int
    let fileName: String
    let newName: String?

    var body: some View {
        HStack(spacing: 1) {
            // LEFT COLUMN - ORIGINAL FILE NAME ONLY (NO ICON)
            HStack(spacing: 8) {
                Text("\(index + 1).")
                    .foregroundColor(.secondary)
                    .frame(width: 35, alignment: .trailing)
                    .font(.system(size: 13))

                Text(fileName)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))

            // RIGHT COLUMN - NEW FILE NAME ONLY (NO CHECKMARK)
            HStack(spacing: 8) {
                if let newFileName = newName {
                    Text(newFileName)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("—")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
        }
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
echo "✅ TEXT-ONLY Version Complete!"
echo ""
echo "📝 NO ICONS - ONLY FILENAMES:"
echo ""
echo "  Left Column:   1. photo1.jpg"
echo "  Right Column:     File_001.jpg"
echo ""
echo "  (No 📷 icons, no ✓ checkmarks)"
echo ""
echo "🚀 Test: open $APP_NAME"
echo ""
