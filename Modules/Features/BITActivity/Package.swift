// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITActivity",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITActivity",
      targets: ["BITActivity"]),
  ],
  dependencies: [
    .package(path: "../BITEntities"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../../Platforms/BITDataStore"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "1.3.1"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITActivity",
      dependencies: [
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITActivityTests",
      dependencies: [
        "BITActivity",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
