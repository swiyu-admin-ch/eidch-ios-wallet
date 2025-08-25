// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITJWT",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITJWT",
      targets: ["BITJWT"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(url: "https://github.com/swiyu-admin-ch/didresolver-swift.git", exact: "2.0.0"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/airsidemobile/JOSESwift.git", exact: "2.4.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITJWT",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "DidResolver", package: "didresolver-swift"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "JOSESwift", package: "JOSESwift"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    .testTarget(
      name: "BITJWTTests",
      dependencies: [
        "BITJWT",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
