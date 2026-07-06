// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FireCalculator",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "FireCalculator",
            path: "Sources/FireCalculator",
            resources: [.process("Resources")]
        )
    ]
)
