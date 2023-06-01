// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RealityCollisions",
  platforms: [.iOS("13.0")],
  products: [
    .library(name: "RealityCollisions", targets: ["RealityCollisions"])
  ],
  dependencies: [],
  targets: [
    .target(name: "RealityCollisions", dependencies: [])
  ],
  swiftLanguageVersions: [.v5]
)
