// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITSdJWT",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITSdJWT",
      targets: ["BITSdJWT"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITClaimsPathPointer"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/airsidemobile/JOSESwift.git", exact: "3.0.0"),
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
        .product(name: "BITClaimsPathPointer", package: "BITClaimsPathPointer"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "JOSESwift", package: "JOSESwift"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITSdJWTTests",
      dependencies: [
        "BITSdJWT",
        "BITAnalytics",
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITClaimsPathPointer", package: "BITClaimsPathPointer"),
      ]),
  ])
