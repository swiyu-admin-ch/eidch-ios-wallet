// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITSettings",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITSettings",
      targets: ["BITSettings"]),
  ],
  dependencies: [
    .package(path: "../BITActivity"),
    .package(path: "../BITAppAuth"),
    .package(path: "../BITAppInfo"),
    .package(path: "../BITEIDRequest"),
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.1.11 available
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/airbnb/lottie-ios", exact: "4.5.1"),
  ],
  targets: [
    .target(
      name: "BITSettings",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITAppInfo", package: "BITAppInfo"),
        .product(name: "BITOTP", package: "BITEIDRequest"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "NavigatorUI", package: "Navigator"),
        .product(name: "PopupView", package: "PopupView"),
        .product(name: "Lottie", package: "lottie-ios"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITSettingsTests",
      dependencies: [
        "BITSettings",
        .product(name: "BITActivity", package: "BITActivity"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITAppInfo", package: "BITAppInfo"),
        .product(name: "BITOTP", package: "BITEIDRequest"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
