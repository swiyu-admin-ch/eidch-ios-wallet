// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITOpenID",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITOpenID",
      targets: ["BITOpenID"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../BITOca"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/KittyMac/Sextant.git", exact: "0.4.33"),
    .package(url: "https://github.com/swiyu-admin-ch/jsonschema-swift.git", branch: "main"),
  ],
  targets: [
    .target(
      name: "BITOpenID",
      dependencies: [
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITSdJWT", package: "BITSdJWT"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Sextant", package: "Sextant"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITOca", package: "BITOca"),
        .product(name: "JsonSchemaValidator", package: "jsonschema-swift"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    .testTarget(
      name: "BITOpenIDTests",
      dependencies: [
        "BITOpenID",
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITSdJWTMocks", package: "BITSdJWT"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITAnyCredentialFormatMocks", package: "BITAnyCredentialFormat"),
        .product(name: "BITAnalyticsMocks", package: "BITAnalytics"),
        .product(name: "JsonSchemaValidator", package: "jsonschema-swift"),
      ],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
  ])
