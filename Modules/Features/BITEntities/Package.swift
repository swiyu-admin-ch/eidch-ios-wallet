// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITEntities",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITEntities",
      targets: ["BITEntities"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITDataStore"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/realm/realm-swift", exact: "10.54.3"),
  ],
  targets: [
    .target(
      name: "BITEntities",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "RealmSwift", package: "realm-swift"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITEntitiesTests",
      dependencies: [
        "BITEntities",
        .product(name: "BITDataStore", package: "BITDataStore"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "RealmSwift", package: "realm-swift"),
      ]),
  ])
