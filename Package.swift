// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "UpdateKit",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "UpdateKit", targets: ["UpdateKit"]),
  ],
  targets: [
    .target(name: "UpdateKit", path: "Sources/UpdateKit"),
  ]
)
