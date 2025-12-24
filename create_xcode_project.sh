#!/bin/bash

# Create Xcode project for macOS app
cat > Package.swift << 'PACKAGE'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BulkRenamer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // CLI executable
        .executable(
            name: "bulk-renamer",
            targets: ["BulkRenamerCLI"]
        ),
        // macOS App
        .executable(
            name: "BulkRenamerApp",
            targets: ["BulkRenamerApp"]
        )
    ],
    targets: [
        // Shared core logic
        .target(
            name: "BulkRenamerCore",
            path: "Sources",
            sources: ["FileRenamer.swift", "NamingPattern.swift"]
        ),
        // CLI version
        .executableTarget(
            name: "BulkRenamerCLI",
            dependencies: ["BulkRenamerCore"],
            path: "Sources",
            sources: ["main.swift"]
        ),
        // macOS App version
        .executableTarget(
            name: "BulkRenamerApp",
            dependencies: ["BulkRenamerCore"],
            path: ".",
            sources: ["BulkRenamerApp.swift"]
        )
    ]
)
PACKAGE

echo "Package.swift updated!"
echo "Run: swift package generate-xcodeproj"
