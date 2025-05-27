// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITSdJWT",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITSdJWT",
      targets: ["BITSdJWT"]),
    .library(
      name: "BITSdJWTMocks",
      targets: ["BITSdJWTMocks"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/airsidemobile/JOSESwift.git", exact: "2.4.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITSdJWT",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "JOSESwift", package: "JOSESwift"),
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
    .target(
      name: "BITSdJWTMocks",
      dependencies: [
        "BITSdJWT",
        .product(name: "BITTestingCore", package: "BITCore"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITSdJWTTests",
      dependencies: [
        "BITSdJWT",
        "BITSdJWTMocks",
        "BITAnalytics",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
