// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITNavigation",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITNavigation",
      targets: ["BITNavigation"]),
  ],
  dependencies: [
    .package(path: "../BITCore"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
  ],
  targets: [
    .target(
      name: "BITNavigation",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "NavigatorUI", package: "Navigator"),
      ]),
  ])
