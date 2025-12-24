import Foundation

/// Core file renaming engine with pattern-based naming
class FileRenamer {
    private let fileManager = FileManager.default

    /// Represents a file to be renamed
    struct FileItem {
        let originalURL: URL
        let originalName: String
        let fileExtension: String
        let creationDate: Date?
        let modificationDate: Date?
        let fileSize: Int64

        init(url: URL) {
            self.originalURL = url
            self.originalName = url.deletingPathExtension().lastPathComponent
            self.fileExtension = url.pathExtension

            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                self.creationDate = attributes[.creationDate] as? Date
                self.modificationDate = attributes[.modificationDate] as? Date
                self.fileSize = attributes[.size] as? Int64 ?? 0
            } else {
                self.creationDate = nil
                self.modificationDate = nil
                self.fileSize = 0
            }
        }
    }

    /// Represents a rename operation
    struct RenameOperation {
        let sourceURL: URL
        let destinationURL: URL
        let newName: String

        var isValid: Bool {
            return sourceURL.path != destinationURL.path
        }
    }

    /// Get all files from a directory (non-recursive by default)
    func getFiles(from directory: URL, recursive: Bool = false, includeHidden: Bool = false) throws -> [FileItem] {
        var files: [FileItem] = []

        if recursive {
            let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: includeHidden ? [] : [.skipsHiddenFiles])

            while let fileURL = enumerator?.nextObject() as? URL {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                   let isRegularFile = resourceValues.isRegularFile,
                   isRegularFile {
                    files.append(FileItem(url: fileURL))
                }
            }
        } else {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: includeHidden ? [] : [.skipsHiddenFiles])

            for fileURL in contents {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                   let isRegularFile = resourceValues.isRegularFile,
                   isRegularFile {
                    files.append(FileItem(url: fileURL))
                }
            }
        }

        return files.sorted { $0.originalName < $1.originalName }
    }

    /// Preview rename operations without executing them
    func previewRename(files: [FileItem], pattern: NamingPattern) -> [RenameOperation] {
        var operations: [RenameOperation] = []

        for (index, file) in files.enumerated() {
            let newName = pattern.apply(to: file, index: index, total: files.count)
            let destinationURL = file.originalURL.deletingLastPathComponent().appendingPathComponent(newName)

            operations.append(RenameOperation(
                sourceURL: file.originalURL,
                destinationURL: destinationURL,
                newName: newName
            ))
        }

        return operations
    }

    /// Execute rename operations
    func executeRename(operations: [RenameOperation], dryRun: Bool = false) throws -> (successful: Int, failed: [(operation: RenameOperation, error: Error)]) {
        var successful = 0
        var failed: [(RenameOperation, Error)] = []

        for operation in operations where operation.isValid {
            if dryRun {
                print("Would rename: \(operation.sourceURL.lastPathComponent) -> \(operation.newName)")
                successful += 1
            } else {
                do {
                    // Check if destination already exists
                    if fileManager.fileExists(atPath: operation.destinationURL.path) {
                        throw RenamerError.destinationExists(operation.destinationURL.path)
                    }

                    try fileManager.moveItem(at: operation.sourceURL, to: operation.destinationURL)
                    successful += 1
                } catch {
                    failed.append((operation, error))
                }
            }
        }

        return (successful, failed)
    }
}

/// Custom errors for the renamer
enum RenamerError: LocalizedError {
    case directoryNotFound(String)
    case destinationExists(String)
    case invalidPattern(String)

    var errorDescription: String? {
        switch self {
        case .directoryNotFound(let path):
            return "Directory not found: \(path)"
        case .destinationExists(let path):
            return "Destination file already exists: \(path)"
        case .invalidPattern(let reason):
            return "Invalid naming pattern: \(reason)"
        }
    }
}
