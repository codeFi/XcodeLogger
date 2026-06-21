// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "XcodeLogger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "XcodeLogger",
            targets: ["XcodeLogger"]
        )
    ],
    targets: [
        .target(
            name: "XcodeLogger",
            path: "Sources/XcodeLogger"
        ),
        .testTarget(
            name: "XcodeLoggerTests",
            dependencies: ["XcodeLogger"],
            path: "Tests/XcodeLoggerTests"
        )
    ]
)
