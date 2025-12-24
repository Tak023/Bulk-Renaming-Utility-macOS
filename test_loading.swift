import Foundation

struct FileItem {
    let url: URL
    let name: String
}

let fm = FileManager.default
let testDir = URL(fileURLWithPath: NSString(string: "~/test-bulk-rename").expandingTildeInPath)

print("Testing file loading from: \(testDir.path)")
print("")

do {
    let contents = try fm.contentsOfDirectory(
        at: testDir,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )
    
    var files: [FileItem] = []
    
    for url in contents {
        if let resourceValues = try? url.resourceValues(forKeys: [.isRegularFileKey]),
           let isRegularFile = resourceValues.isRegularFile,
           isRegularFile {
            files.append(FileItem(url: url, name: url.lastPathComponent))
        }
    }
    
    print("✅ Found \(files.count) files")
    print("")
    
    for (index, file) in files.enumerated() {
        print("\(index + 1). \(file.name)")
    }
    
} catch {
    print("❌ Error: \(error.localizedDescription)")
}
