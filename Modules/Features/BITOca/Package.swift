// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITOca",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITOca",
      targets: ["BITOca"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITJsonCanonicalizer"),
    .package(path: "../../Platforms/BITClaimsPathPointer"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITOca",
      dependencies: [
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITJsonCanonicalizer", package: "BITJsonCanonicalizer"),
        .product(name: "BITClaimsPathPointer", package: "BITClaimsPathPointer"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Factory", package: "Factory"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITOcaTests",
      dependencies: [
        "BITOca",
        .product(name: "BITTestingCore", package: "BITCore"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
