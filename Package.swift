// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CollisionFiltersv",
  platforms: [.iOS("13.0")],
  products: [
    .library(name: "CollisionFilters", targets: ["CollisionFilters"])
  ],
  dependencies: [],
  targets: [
    .target(name: "CollisionFilters", dependencies: [])
  ],
  swiftLanguageVersions: [.v5]
)
