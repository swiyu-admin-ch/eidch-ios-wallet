// swift-tools-version: 6.3

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
    .package(path: "../../Platforms/BITCrypto"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/realm/realm-swift", exact: "20.0.5"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITDataStore",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITCrypto", package: "BITCrypto"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "RealmSwift", package: "realm-swift"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITDataStoreTests",
      dependencies: [
        "BITDataStore",
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "FactoryTesting", package: "Factory"),
        .product(name: "RealmSwift", package: "realm-swift"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
