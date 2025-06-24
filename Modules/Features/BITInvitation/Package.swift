// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITInvitation",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITInvitation",
      targets: ["BITInvitation"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITDeeplink"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITQRCode"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITAnyCredentialFormat"),
    .package(path: "../../Features/BITCredential"),
    .package(path: "../../Features/BITCredentialShared"),
    .package(path: "../../Features/BITPresentation"),
    .package(path: "../../Features/BITOpenID"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.0.2 available
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITInvitation",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITOpenID", package: "BITOpenID"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITNavigation", package: "BITNavigation"),
        .product(name: "BITDeeplink", package: "BITDeeplink"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITQRCode", package: "BITQRCode"),
        .product(name: "BITCredential", package: "BITCredential"),
        .product(name: "BITCredentialShared", package: "BITCredentialShared"),
        .product(name: "BITPresentation", package: "BITPresentation"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITAnyCredentialFormat", package: "BITAnyCredentialFormat"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "PopupView", package: "PopupView"),
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
    .testTarget(
      name: "BITInvitationTests",
      dependencies: [
        "BITInvitation",
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "BITNavigationTestCore", package: "BITNavigation"),
        .product(name: "BITSdJWTMocks", package: "BITSdJWT"),
        .product(name: "BITAnalyticsMocks", package: "BITAnalytics"),
        .product(name: "BITAnyCredentialFormatMocks", package: "BITAnyCredentialFormat"),
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
  ])
