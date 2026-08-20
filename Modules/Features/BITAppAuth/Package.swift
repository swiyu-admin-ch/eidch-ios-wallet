// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITAppAuth",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITAppAuth",
      targets: ["BITAppAuth"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.1.11 available
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITLocalAuthentication"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITDataStore"),
    .package(path: "../BITAppInfo"),
  ],
  targets: [
    .target(
      name: "BITAppAuth",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "PopupView", package: "PopupView"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITLocalAuthentication", package: "BITLocalAuthentication"),
        .product(name: "BITNavigation", package: "BITNavigation"),
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "BITAppInfo", package: "BITAppInfo"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITAppAuthTests",
      dependencies: [
        "BITAppAuth",
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "FactoryTesting", package: "Factory"),
        .product(name: "BITNavigation", package: "BITNavigation"),
        .product(name: "BITAppInfo", package: "BITAppInfo"),
        .product(name: "BITNavigation", package: "BITNavigation"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
