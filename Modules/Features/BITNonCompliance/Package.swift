// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITNonCompliance",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITNonCompliance",
      targets: ["BITNonCompliance"]),
  ],
  dependencies: [
    .package(path: "../BITActivity"),
    .package(path: "../BITCredential"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "1.3.1"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITNonCompliance",
      dependencies: [
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITCredential", package: "BITCredential"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITNonComplianceTests",
      dependencies: [
        "BITNonCompliance",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
