// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITEIDRequest",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITEIDRequest",
      targets: ["BITEIDRequest"]),
    .library(
      name: "BITOTP",
      targets: ["BITOTP"]),
  ],
  dependencies: [
    .package(path: "../BITOpenID"),
    .package(path: "../BITEntities"),
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITAppAuth"),
    .package(path: "../BITCredential"),
    .package(path: "../BITEIDRequestShared"),
    .package(path: "../BITInvitation"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITNavigation"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(path: "../BITPushNotification"),
    .package(path: "../../Platforms/BITQRCode"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.1.11 available
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", exact: "0.18.0"),
    .package(url: "https://github.com/devicekit/DeviceKit.git", exact: "5.7.0"),
    .package(url: "https://github.com/swiyu-admin-ch/eidch-ios-av-lib.git", exact: "0.23.1"),
  ],
  targets: [
    .target(
      name: "BITEIDRequest",
      dependencies: [
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITEIDRequestShared", package: "BITEIDRequestShared"),
        .product(name: "BITOpenID", package: "BITOpenID"),
        .product(name: "BITCredential", package: "BITCredential"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITInvitation", package: "BITInvitation"),
        .product(name: "BITQRCode", package: "BITQRCode"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITNavigation", package: "BITNavigation"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITPushNotification", package: "BITPushNotification"),
        .product(name: "BITEntities", package: "BITEntities"),
        .product(name: "BITAVWrapper", package: "eidch-ios-av-lib"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "PopupView", package: "PopupView"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "XMLCoder", package: "XMLCoder"),
        .product(name: "DeviceKit", package: "DeviceKit"),
      ],
      resources: [.process("Resources")]),
    .target(
      name: "BITOTP",
      dependencies: [
        "BITEIDRequest",
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")],
      // Swift 6 language mode crashes swift-frontend 6.3.2 during IRGen of
      // OTPCodeView, while emitting the `@$sSSScA_pSgIeAghgg_SSIeAghn_TR`
      // reabstraction thunk. Keep this target in Swift 5 mode until it is fixed.
      swiftSettings: [.swiftLanguageMode(.v5)]),
    .testTarget(
      name: "BITOTPTests",
      dependencies: [
        "BITOTP",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
    .testTarget(
      name: "BITEIDRequestTests",
      dependencies: [
        "BITEIDRequest",
        .product(name: "BITPushNotification", package: "BITPushNotification"),
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "FactoryTesting", package: "Factory"),
      ]),
  ])
