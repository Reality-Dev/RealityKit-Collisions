// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RealityCollisions",
  platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
  products: [
    .library(name: "RealityCollisions", targets: ["RealityCollisions"])
  ],
  dependencies: [],
  targets: [
    .target(name: "RealityCollisions", dependencies: [])
  ],
  swiftLanguageVersions: [.v5]
)
