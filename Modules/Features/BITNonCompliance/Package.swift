// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITNonCompliance",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITNonCompliance",
      targets: ["BITNonCompliance"]),
  ],
  dependencies: [
    .package(path: "../BITActivity"),
    .package(path: "../BITAppAuth"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITOpenID"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITSwiyuSharedKMP"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITNonCompliance",
      dependencies: [
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITSwiyuSharedKMP", package: "BITSwiyuSharedKMP"),
        .product(name: "BITOpenID", package: "BITOpenID"),
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
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITOpenID", package: "BITOpenID"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
