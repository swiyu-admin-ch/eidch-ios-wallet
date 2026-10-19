// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITQRCode",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITQRCode",
      targets: ["BITQRCode"]),
  ],
  dependencies: [
    .package(path: "../BITTheming"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITQRCode",
      dependencies: [
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
  ])
