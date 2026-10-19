// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITVault",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITVault",
      targets: ["BITVault"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
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
