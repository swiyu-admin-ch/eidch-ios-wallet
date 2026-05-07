// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    .library(
      name: "BITAnalyticsMocks",
      targets: ["BITAnalyticsMocks"]),
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
    .target(
      name: "BITAnalyticsMocks",
      dependencies: [
        "BITAnalytics",
      ]),
    .testTarget(
      name: "BITAnalyticsTests",
      dependencies: [
        "BITAnalytics",
        "BITAnalyticsMocks",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
