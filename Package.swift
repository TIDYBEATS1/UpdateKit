// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UpdateKit",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "UpdateKit", targets: ["UpdateKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "UpdateKit",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ]
        )
    ]
)
