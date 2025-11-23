// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEspeak",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        // Library product for SwiftEspeak framework
        .library(
            name: "SwiftEspeak",
            targets: ["SwiftEspeak"]
        ),
        // Executable product for CLI tool
        .executable(
            name: "swift-espeak",
            targets: ["SwiftEspeakCLI"]
        )
    ],
    dependencies: [
        // Swift Argument Parser for CLI argument handling
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.0"
        ),
    ],
    targets: [
        // C module for eSpeak-NG bridging
        .systemLibrary(
            name: "CEspeak",
            pkgConfig: "espeak-ng",
            providers: [
                .brew(["espeak-ng"]),
                .apt(["libespeak-ng-dev"])
            ]
        ),
        // Main library target
        .target(
            name: "SwiftEspeak",
            dependencies: ["CEspeak"]
        ),
        // CLI executable target
        .executableTarget(
            name: "SwiftEspeakCLI",
            dependencies: [
                "SwiftEspeak",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        // Test target
        .testTarget(
            name: "SwiftEspeakTests",
            dependencies: ["SwiftEspeak"]
        )
    ]
)
