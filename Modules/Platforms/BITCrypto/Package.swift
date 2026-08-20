// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITCrypto",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITCrypto",
      targets: ["BITCrypto"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITAnalytics"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift", exact: "1.8.4"),
    .package(url: "https://github.com/amosavian/JWSETKit", exact: "2.2.0"),
  ],
  targets: [
    .target(
      name: "BITCrypto",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "CryptoSwift", package: "CryptoSwift"),
        .product(name: "JWSETKit", package: "JWSETKit"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
    .testTarget(
      name: "BITCryptoTests",
      dependencies: [
        "BITCrypto",
        .product(name: "BITTestingCore", package: "BITCore"),
        .product(name: "JWSETKit", package: "JWSETKit"),
      ],
      swiftSettings: [
        .define("DEBUG", .when(configuration: .debug)),
      ]),
  ])
