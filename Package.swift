// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KaijuRampage",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "KaijuRampage", targets: ["KaijuRampage"])
    ],
    targets: [
        .executableTarget(
            name: "KaijuRampage",
            path: "Sources/KaijuRampage"
        ),
        .testTarget(
            name: "KaijuRampageTests",
            dependencies: ["KaijuRampage"],
            path: "Tests/KaijuRampageTests"
        )
    ]
)
