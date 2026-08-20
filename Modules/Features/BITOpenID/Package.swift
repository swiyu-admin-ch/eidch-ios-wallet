// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITOpenID",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITOpenID",
      targets: ["BITOpenID"]),
  ],
  dependencies: [
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITAppAuth"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITCrypto"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITLocalAuthentication"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../../Platforms/BITClaimsPathPointer"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITSwiyuSharedKMP"),
    .package(path: "../BITOca"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/swiyu-admin-ch/jsonschema-swift.git", exact: "0.46.4"),
  ],
  targets: [
    .target(
      name: "BITOpenID",
      dependencies: [
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITSdJWT", package: "BITSdJWT"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITClaimsPathPointer", package: "BITClaimsPathPointer"),
        .product(name: "BITSwiyuSharedKMP", package: "BITSwiyuSharedKMP"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "BITOca", package: "BITOca"),
        .product(name: "JsonSchemaValidator", package: "jsonschema-swift"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    .testTarget(
      name: "BITOpenIDTests",
      dependencies: [
        "BITOpenID",
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITLocalAuthentication", package: "BITLocalAuthentication"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITClaimsPathPointer", package: "BITClaimsPathPointer"),
        .product(name: "BITSdJWT", package: "BITSdJWT"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITSwiyuSharedKMP", package: "BITSwiyuSharedKMP"),
        .product(name: "JsonSchemaValidator", package: "jsonschema-swift"),
        .product(name: "FactoryTesting", package: "Factory"),
      ],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
  ])
