// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITEIDRequest",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITEIDRequest",
      targets: ["BITEIDRequest"]),
  ],
  dependencies: [
    .package(path: "../BITEntities"),
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITAppAuth"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITQRCode"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.1.11 available
    .package(url: "git@github.com:admin-ch-ssi/PERA_av-wrapper-private_ios.git", revision: "02f2c7104bbed15f048970850df926738a8e3812"),
  ],
  targets: [
    .target(
      name: "BITEIDRequest",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "BITQRCode", package: "BITQRCode"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITNavigation", package: "BITNavigation"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITAVWrapper", package: "eidch-ios-av-lib"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITEIDRequestTests",
      dependencies: [
        "BITEIDRequest",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
