// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITAppAttestation",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITAppAttestation",
      targets: ["BITAppAttestation"]),
  ],
  dependencies: [
    .package(path: "../BITEntities"),
    .package(path: "../BITAppInfo"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITJsonCanonicalizer"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITDataStore"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
  ],
  targets: [
    .target(
      name: "BITAppAttestation",
      dependencies: [
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITAppInfo", package: "BITAppInfo"),
        .product(name: "BITJsonCanonicalizer", package: "BITJsonCanonicalizer"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITAppAttestationTests",
      dependencies: [
        "BITAppAttestation",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
