// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITAnalytics",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITAnalytics",
      targets: ["BITAnalytics"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/Dynatrace/swift-mobile-sdk.git", exact: "8.309.1"),
    .package(path: "../../Platforms/BITCore"),
  ],
  targets: [
    .target(
      name: "BITAnalytics",
      dependencies: [
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Dynatrace", package: "swift-mobile-sdk"),
      ]),
    .testTarget(
      name: "BITAnalyticsTests",
      dependencies: [
        "BITAnalytics",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
