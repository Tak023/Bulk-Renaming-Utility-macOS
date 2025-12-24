// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BulkRenamer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "bulk-renamer",
            targets: ["BulkRenamer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "BulkRenamer",
            path: "Sources"
        )
    ]
)
