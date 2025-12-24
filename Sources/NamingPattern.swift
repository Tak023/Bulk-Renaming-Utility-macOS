import Foundation

/// Naming pattern system with various manipulation tools
class NamingPattern {
    private var components: [PatternComponent] = []

    /// Add a pattern component
    func add(_ component: PatternComponent) {
        components.append(component)
    }

    /// Apply the pattern to a file
    func apply(to file: FileRenamer.FileItem, index: Int, total: Int) -> String {
        var result = ""

        for component in components {
            result += component.render(file: file, index: index, total: total)
        }

        // Add extension if not already included
        if !result.hasSuffix(".\(file.fileExtension)") && !file.fileExtension.isEmpty {
            result += ".\(file.fileExtension)"
        }

        return result
    }

    /// Create pattern from string template
    static func from(template: String) -> NamingPattern {
        let pattern = NamingPattern()

        // Parse template string and extract tokens
        var currentText = ""
        var i = template.startIndex

        while i < template.endIndex {
            if template[i] == "{" {
                // Save any accumulated text
                if !currentText.isEmpty {
                    pattern.add(.text(currentText))
                    currentText = ""
                }

                // Find closing brace
                if let closingBrace = template[i...].firstIndex(of: "}") {
                    let tokenStart = template.index(after: i)
                    let token = String(template[tokenStart..<closingBrace])

                    // Parse token
                    if let component = parseToken(token) {
                        pattern.add(component)
                    }

                    i = template.index(after: closingBrace)
                    continue
                }
            }

            currentText.append(template[i])
            i = template.index(after: i)
        }

        // Add remaining text
        if !currentText.isEmpty {
            pattern.add(.text(currentText))
        }

        return pattern
    }

    private static func parseToken(_ token: String) -> PatternComponent? {
        let parts = token.split(separator: ":", maxSplits: 1).map(String.init)
        let command = parts[0].lowercased()
        let args = parts.count > 1 ? parts[1] : ""

        switch command {
        case "counter":
            let components = args.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let start = components.first.flatMap(Int.init) ?? 1
            let padding = components.count > 1 ? (Int(components[1]) ?? 3) : 3
            return .counter(start: start, padding: padding)

        case "name", "original":
            return .originalName

        case "date":
            let format = args.isEmpty ? "yyyy-MM-dd" : args
            return .date(format: format, useCreation: false)

        case "created", "creation":
            let format = args.isEmpty ? "yyyy-MM-dd" : args
            return .date(format: format, useCreation: true)

        case "ext", "extension":
            return .extension

        case "upper", "uppercase":
            return .transform(.uppercase)

        case "lower", "lowercase":
            return .transform(.lowercase)

        case "capitalize", "title":
            return .transform(.capitalized)

        case "size":
            return .fileSize

        case "random":
            let length = Int(args) ?? 8
            return .random(length: length)

        case "uuid":
            return .uuid

        case "parent":
            return .parentFolder

        default:
            return .text("{\(token)}")
        }
    }
}

/// Pattern components for building file names
enum PatternComponent {
    case text(String)
    case counter(start: Int, padding: Int)
    case originalName
    case date(format: String, useCreation: Bool)
    case `extension`
    case transform(TextTransform)
    case fileSize
    case random(length: Int)
    case uuid
    case parentFolder

    func render(file: FileRenamer.FileItem, index: Int, total: Int) -> String {
        switch self {
        case .text(let str):
            return str

        case .counter(let start, let padding):
            let number = start + index
            return String(format: "%0\(padding)d", number)

        case .originalName:
            return file.originalName

        case .date(let format, let useCreation):
            let date = useCreation ? (file.creationDate ?? Date()) : (file.modificationDate ?? Date())
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)

        case .extension:
            return file.fileExtension

        case .transform(let transform):
            return transform.apply(to: file.originalName)

        case .fileSize:
            return ByteCountFormatter.string(fromByteCount: file.fileSize, countStyle: .file)

        case .random(let length):
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map { _ in characters.randomElement()! })

        case .uuid:
            return UUID().uuidString

        case .parentFolder:
            return file.originalURL.deletingLastPathComponent().lastPathComponent
        }
    }
}

/// Text transformation options
enum TextTransform {
    case uppercase
    case lowercase
    case capitalized

    func apply(to text: String) -> String {
        switch self {
        case .uppercase:
            return text.uppercased()
        case .lowercase:
            return text.lowercased()
        case .capitalized:
            return text.capitalized
        }
    }
}

/// Pattern builder for fluent API
class PatternBuilder {
    private let pattern = NamingPattern()

    func text(_ str: String) -> PatternBuilder {
        pattern.add(.text(str))
        return self
    }

    func counter(start: Int = 1, padding: Int = 3) -> PatternBuilder {
        pattern.add(.counter(start: start, padding: padding))
        return self
    }

    func originalName() -> PatternBuilder {
        pattern.add(.originalName)
        return self
    }

    func date(format: String = "yyyy-MM-dd", useCreation: Bool = false) -> PatternBuilder {
        pattern.add(.date(format: format, useCreation: useCreation))
        return self
    }

    func fileExtension() -> PatternBuilder {
        pattern.add(.extension)
        return self
    }

    func uppercase() -> PatternBuilder {
        pattern.add(.transform(.uppercase))
        return self
    }

    func lowercase() -> PatternBuilder {
        pattern.add(.transform(.lowercase))
        return self
    }

    func capitalized() -> PatternBuilder {
        pattern.add(.transform(.capitalized))
        return self
    }

    func fileSize() -> PatternBuilder {
        pattern.add(.fileSize)
        return self
    }

    func random(length: Int = 8) -> PatternBuilder {
        pattern.add(.random(length: length))
        return self
    }

    func uuid() -> PatternBuilder {
        pattern.add(.uuid)
        return self
    }

    func parentFolder() -> PatternBuilder {
        pattern.add(.parentFolder)
        return self
    }

    func build() -> NamingPattern {
        return pattern
    }
}
