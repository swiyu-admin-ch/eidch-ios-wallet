// swift-tools-version: 5.9
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
    .package(path: "../BITAppAuth"),
    .package(path: "../BITOca"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/KittyMac/Sextant.git", revision: "e59c57e4fa19a02f336cd91b9f6cd8e4022e5ed0"),
  ],
  targets: [
    .target(
      name: "BITOpenID",
      dependencies: [
        .product(name: "BITAppAuth", package: "BITAppAuth"),
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
      ],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
  ])
