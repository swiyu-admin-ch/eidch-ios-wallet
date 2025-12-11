// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITNavigation",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITNavigation",
      targets: ["BITNavigation"]),
    .library(
      name: "BITNavigationTestCore",
      targets: ["BITNavigationTestCore"]),
  ],
  dependencies: [
    .package(path: "../BITCore"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "1.3.1"),
  ],
  targets: [
    .target(
      name: "BITNavigation",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "NavigatorUI", package: "Navigator"),
      ]),
    .target(
      name: "BITNavigationTestCore",
      dependencies: ["BITNavigation"],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITNavigationTests",
      dependencies: ["BITNavigation"]),
  ])
