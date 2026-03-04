// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "pastemax",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "pastemax",
            path: "Sources/pastemax"
        )
    ]
)
