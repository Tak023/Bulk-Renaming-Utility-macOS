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

struct ContentView: View {
    @State private var selectedDirectory: URL?
    @State private var pattern: String = "Photo_{counter:1,4}"
    @State private var files: [FileRenamer.FileItem] = []
    @State private var previewOperations: [FileRenamer.RenameOperation] = []
    @State private var showingPreview = false
    @State private var statusMessage = ""
    @State private var showingFilePicker = false

    private let renamer = FileRenamer()

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                if let nsImage = NSImage(contentsOfFile: Bundle.main.path(forResource: "AppIcon", ofType: "png") ?? "") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 96, height: 96)
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
            .padding(.top, 20)

            Divider()

            // Directory Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Step 1: Select Directory")
                    .font(.headline)

                HStack {
                    if let dir = selectedDirectory {
                        VStack(alignment: .leading) {
                            Text(dir.lastPathComponent)
                                .font(.body)
                                .fontWeight(.semibold)
                            Text(dir.path)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        Text(fileCount)
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else {
                        Text("No directory selected")
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    Button(action: selectDirectory) {
                        Label("Choose", systemImage: "folder")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            // Pattern Input
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Step 2: Enter Pattern")
                        .font(.headline)

                    Spacer()

                    Button(action: { showPatternHelp() }) {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.plain)
                }

                TextField("Enter naming pattern", text: $pattern)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                // Quick pattern buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        QuickPatternButton(title: "Counter", pattern: "File_{counter:1,3}", current: $pattern)
                        QuickPatternButton(title: "Date + Counter", pattern: "{date:yyyy-MM-dd}_{counter:1,3}", current: $pattern)
                        QuickPatternButton(title: "Keep Name", pattern: "{name}_{counter:1,2}", current: $pattern)
                        QuickPatternButton(title: "Parent Folder", pattern: "{parent}_{counter:1,3}", current: $pattern)
                    }
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: preview) {
                    Label("Preview", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(selectedDirectory == nil || pattern.isEmpty)

                Button(action: execute) {
                    Label("Rename Files", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedDirectory == nil || pattern.isEmpty || previewOperations.isEmpty)
            }

            // Status Message
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(statusMessage.contains("✅") ? .green : .red)
                    .padding(.horizontal)
            }

            // Two Column Display - Shows files when selected, preview when available
            if !files.isEmpty || !previewOperations.isEmpty {
                FileDisplayBox(
                    files: files,
                    operations: previewOperations,
                    showingPreview: showingPreview
                )
            }

            Spacer()
        }
        .padding()
        .frame(width: 800, height: (!files.isEmpty || !previewOperations.isEmpty) ? 750 : 450)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedDirectory = url
                    loadFiles(from: url)
                    previewOperations = []
                    showingPreview = false
                }
            case .failure(let error):
                statusMessage = "❌ Error: \(error.localizedDescription)"
            }
        }
    }

    private var fileCount: String {
        return files.isEmpty ? "" : "\(files.count) files"
    }

    private func loadFiles(from directory: URL) {
        do {
            files = try renamer.getFiles(from: directory)
            statusMessage = files.isEmpty ? "⚠️ No files found" : ""
        } catch {
            statusMessage = "❌ Error: \(error.localizedDescription)"
            files = []
        }
    }

    private func selectDirectory() {
        showingFilePicker = true
    }

    private func preview() {
        guard !files.isEmpty else {
            statusMessage = "⚠️ No files to preview"
            return
        }

        let namingPattern = NamingPattern.from(template: pattern)
        previewOperations = renamer.previewRename(files: files, pattern: namingPattern)
        showingPreview = true
        statusMessage = "👁️ Preview ready - \(previewOperations.count) files"
    }

    private func execute() {
        guard !previewOperations.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = "Confirm Rename"
        alert.informativeText = "Are you sure you want to rename \(previewOperations.count) file(s)? This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            do {
                let result = try renamer.executeRename(operations: previewOperations)
                statusMessage = "✅ Successfully renamed \(result.successful) file(s)"

                if !result.failed.isEmpty {
                    statusMessage += "\n❌ Failed: \(result.failed.count) file(s)"
                }

                // Reload files and reset preview
                if let dir = selectedDirectory {
                    loadFiles(from: dir)
                }
                previewOperations = []
                showingPreview = false
            } catch {
                statusMessage = "❌ Error: \(error.localizedDescription)"
            }
        }
    }

    private func showPatternHelp() {
        let alert = NSAlert()
        alert.messageText = "Pattern Tokens"
        alert.informativeText = """
        {counter:start,padding} - Sequential numbers
        {name} - Original filename
        {date:format} - File date
        {parent} - Parent folder
        {random:length} - Random string
        {uuid} - Unique ID

        Examples:
        • Photo_{counter:1,4}
        • {date:yyyy-MM-dd}_{counter:1,3}
        • {parent}_{name}_{counter:1,2}
        """
        alert.addButton(withTitle: "OK")
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

struct FileDisplayBox: View {
    let files: [FileRenamer.FileItem]
    let operations: [FileRenamer.RenameOperation]
    let showingPreview: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(showingPreview ? "Preview (\(operations.count) files)" : "Files (\(files.count))")
                .font(.title2)
                .fontWeight(.bold)

            displayTable

            let itemCount = showingPreview ? operations.count : files.count
            if itemCount > 50 {
                Text("... and \(itemCount - 50) more files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var displayTable: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
            contentRows
        }
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Original Files")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.blue.opacity(0.5))

            Divider()

            Text("New Files")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.green.opacity(0.5))
        }
        .background(Color.gray.opacity(0.2))
    }

    private var contentRows: some View {
        ScrollView {
            VStack(spacing: 0) {
                if showingPreview {
                    ForEach(Array(operations.prefix(50).enumerated()), id: \.offset) { index, operation in
                        previewRow(index: index, operation: operation)
                        if index < min(49, operations.count - 1) {
                            Divider()
                        }
                    }
                } else {
                    ForEach(Array(files.prefix(50).enumerated()), id: \.offset) { index, file in
                        fileOnlyRow(index: index, file: file)
                        if index < min(49, files.count - 1) {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(height: 300)
    }

    private func previewRow(index: Int, operation: FileRenamer.RenameOperation) -> some View {
        HStack(spacing: 0) {
            columnContent(
                index: index,
                text: operation.sourceURL.lastPathComponent,
                isBold: false
            )
            Divider()
            columnContent(
                index: nil,
                text: operation.newName,
                isBold: true
            )
        }
        .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
    }

    private func fileOnlyRow(index: Int, file: FileRenamer.FileItem) -> some View {
        HStack(spacing: 0) {
            columnContent(
                index: index,
                text: file.originalURL.lastPathComponent,
                isBold: false
            )
            Divider()
            emptyColumn()
        }
        .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
    }

    private func columnContent(index: Int?, text: String, isBold: Bool) -> some View {
        HStack {
            if let idx = index {
                Text("\(idx + 1).")
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .font(.caption.monospacedDigit())
            }

            Text(text)
                .font(.caption)
                .fontWeight(isBold ? .semibold : .regular)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(8)
    }

    private func emptyColumn() -> some View {
        HStack {
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(8)
    }
}
