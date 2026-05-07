// swift-tools-version: 5.10.1
import PackageDescription

let package = Package(
  name: "BITCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITCore",
      targets: ["BITCore"]),
    .library(
      name: "BITTestingCore",
      targets: ["BITTestingCore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/Flight-School/AnyCodable", exact: "0.6.7"),
  ],
  targets: [
    .target(
      name: "BITCore",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "AnyCodable", package: "AnyCodable"),
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .target(
      name: "BITTestingCore",
      dependencies: ["BITCore"],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITCoreTests",
      dependencies: ["BITCore", "BITTestingCore"]),
  ])
