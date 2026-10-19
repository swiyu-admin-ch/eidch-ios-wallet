// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITEIDRequestShared",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITEIDRequestShared",
      targets: ["BITEIDRequestShared"]),
  ],
  dependencies: [
    .package(path: "../BITEntities"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../../Platforms/BITCore"),
    .package(url: "https://github.com/swiyu-admin-ch/eidch-ios-av-lib.git", exact: "0.23.1"),
  ],
  targets: [
    .target(
      name: "BITEIDRequestShared",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITAVWrapper", package: "eidch-ios-av-lib"),
      ],
      resources: [.process("Resources")]),
  ])
