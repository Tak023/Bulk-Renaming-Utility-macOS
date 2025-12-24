import Foundation

let fm = FileManager.default
let testPath = "/Users/mike/Desktop"

print("Testing file access...")
print("Path: \(testPath)")

do {
    let contents = try fm.contentsOfDirectory(atPath: testPath)
    print("✅ Can access directory")
    print("Found \(contents.count) items")
    for item in contents.prefix(5) {
        print("  - \(item)")
    }
} catch {
    print("❌ Error: \(error)")
}
