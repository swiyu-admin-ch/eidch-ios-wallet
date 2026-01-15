// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITEIDRequestShared",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
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
    .package(url: "https://github.com/swiyu-admin-ch/eidch-ios-av-lib.git", exact: "0.17.1"),
  ],
  targets: [
    .target(
      name: "BITEIDRequestShared",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITAVWrapper", package: "eidch-ios-av-lib"),
      ],
      resources: [.process("Resources")]),
  ])
