// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITDataStore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITDataStore",
      targets: ["BITDataStore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
    .package(url: "https://github.com/realm/realm-swift", exact: "10.50.0"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITDataStore",
      dependencies: [
        .product(name: "Factory", package: "Factory"),
        .product(name: "RealmSwift", package: "realm-swift"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITDataStoreTests",
      dependencies: ["BITDataStore"],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
