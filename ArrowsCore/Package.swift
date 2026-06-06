// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ArrowsCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(name: "ArrowsCore", targets: ["ArrowsCore"]),
    ],
    targets: [
        .target(name: "ArrowsCore"),
        .testTarget(name: "ArrowsCoreTests", dependencies: ["ArrowsCore"]),
    ]
)
