// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITVault",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITVault",
      targets: ["BITVault"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(path: "../../Platforms/BITLocalAuthentication"),
  ],
  targets: [
    .target(
      name: "BITVault",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "BITLocalAuthentication", package: "BITLocalAuthentication"),
        .product(name: "Factory", package: "Factory"),
      ]),
    .testTarget(
      name: "BITVaultTests",
      dependencies: ["BITVault"]),
  ])
