// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ClaudeToolbar",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ClaudeToolbar",
            path: "Sources/ClaudeToolbar"
        )
    ]
)
