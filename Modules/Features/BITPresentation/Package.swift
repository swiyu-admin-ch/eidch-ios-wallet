// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITPresentation",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITPresentation",
      targets: ["BITPresentation"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../BITCredentialShared"),
    .package(path: "../BITAppAuth"),
    .package(path: "../BITCredential"),
    .package(path: "../BITActivity"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(path: "../../Platforms/BITJWT"),
    .package(path: "../../Platforms/BITVault"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITLocalAuthentication"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../../Platforms/BITSwiyuSharedKMP"),
    .package(path: "../BITOpenID"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/KittyMac/Sextant.git", exact: "0.4.33"),
  ],
  targets: [
    .target(
      name: "BITPresentation",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITCredential", package: "BITCredential"),
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITSdJWT", package: "BITSdJWT"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITVault", package: "BITVault"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITLocalAuthentication", package: "BITLocalAuthentication"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Sextant", package: "Sextant"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "BITSwiyuSharedKMP", package: "BITSwiyuSharedKMP"),
        .product(name: "BITOpenID", package: "BITOpenID"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
    .testTarget(
      name: "BITPresentationTests",
      dependencies: [
        "BITPresentation",
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITAnyCredentialFormatMocks", package: "BITAnyCredentialFormat"),
        .product(name: "BITSdJWTMocks", package: "BITSdJWT"),
        .product(name: "BITJWT", package: "BITJWT"),
        .product(name: "BITNavigationTestCore", package: "BITNavigation"),
        .product(name: "BITAnalyticsMocks", package: "BITAnalytics"),
      ],
      swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
  ])
