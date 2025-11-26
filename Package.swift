// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FoundationModelsKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "FoundationModelsKit",
            targets: ["FoundationModelsKit"]
        ),
        .executable(
            name: "FoundationModelsDemo",
            targets: ["FoundationModelsDemo"]
        )
    ],
    targets: [
        .target(
            name: "FoundationModelsKit",
            dependencies: [],
            path: "Sources/FoundationModelsKit"
        ),
        .executableTarget(
            name: "FoundationModelsDemo",
            dependencies: ["FoundationModelsKit"],
            path: "Examples/Demo"
        ),
        .testTarget(
            name: "FoundationModelsKitTests",
            dependencies: ["FoundationModelsKit"],
            path: "Tests/FoundationModelsKitTests"
        )
    ]
)
