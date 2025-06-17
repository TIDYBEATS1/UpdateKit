// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UpdateKit",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "UpdateKit", targets: ["UpdateKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UpdateKit",
            dependencies: []
        )
    ]
)
