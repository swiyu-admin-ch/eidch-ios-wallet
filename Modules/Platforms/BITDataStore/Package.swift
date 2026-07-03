// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITDataStore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITDataStore",
      targets: ["BITDataStore"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/realm/realm-swift", exact: "20.0.4"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITDataStore",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
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
