// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITActivityDetail",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITActivityDetail",
      targets: ["BITActivityDetail"]),
  ],
  dependencies: [
    .package(path: "../BITActivity"),
    .package(path: "../BITCredential"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../BITNonCompliance"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITActivityDetail",
      dependencies: [
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITCredential", package: "BITCredential"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITNonCompliance", package: "BITNonCompliance"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITActivityDetailTests",
      dependencies: [
        "BITActivityDetail",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
