// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITCredential",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITCredential",
      targets: ["BITCredential"]),
  ],
  dependencies: [
    .package(path: "../BITAppAuth"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITDataStore"),
    .package(path: "../../Platforms/BITLocalAuthentication"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../BITOpenID"),
    .package(path: "../BITOca"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/KittyMac/Sextant.git", exact: "0.4.33"),
    .package(url: "https://github.com/gh123man/SwiftUI-Refresher", exact: "1.1.9"),
    .package(url: "https://github.com/realm/realm-swift", exact: "10.54.3"),
  ],
  targets: [
    .target(
      name: "BITCredential",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "BITLocalAuthentication", package: "BITLocalAuthentication"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITOpenID", package: "BITOpenID"),
        .product(name: "BITOca", package: "BITOca"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Sextant", package: "Sextant"),
        .product(name: "Refresher", package: "SwiftUI-Refresher"),
        .product(name: "RealmSwift", package: "realm-swift"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITCredentialTests",
      dependencies: [
        "BITCredential",
        "BITSdJWT",
        .product(name: "BITAnyCredentialFormatMocks", package: "BITAnyCredentialFormat"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITSdJWTMocks", package: "BITSdJWT"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITAnalyticsMocks", package: "BITAnalytics"),
        .product(name: "BITNavigationTestCore", package: "BITNavigation"),
        .product(name: "RealmSwift", package: "realm-swift"),
      ]),
  ])
