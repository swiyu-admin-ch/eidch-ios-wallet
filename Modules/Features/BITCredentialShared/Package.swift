// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITCredentialShared",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITCredentialShared",
      targets: ["BITCredentialShared"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../BITEntities"),
    .package(path: "../BITOpenID"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
  ],
  targets: [
    .target(
      name: "BITCredentialShared",
      dependencies: [
        .product(name: "BITOpenID", package: "BITOpenID"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "Factory", package: "Factory"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITCredentialSharedTests",
      dependencies: [
        "BITCredentialShared",
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "Factory", package: "Factory"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
