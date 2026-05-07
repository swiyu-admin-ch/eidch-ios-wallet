// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITDeeplink",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITDeeplink",
      targets: ["BITDeeplink"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
  ],
  targets: [
    .target(
      name: "BITDeeplink",
      dependencies: [
        .product(name: "Factory", package: "Factory"),
      ]),
    .testTarget(
      name: "BITDeeplinkTests",
      dependencies: ["BITDeeplink"]),
  ])
