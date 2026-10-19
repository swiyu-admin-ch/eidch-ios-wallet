// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITJsonCanonicalizer",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITJsonCanonicalizer",
      targets: ["BITJsonCanonicalizer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
  ],
  targets: [
    .target(
      name: "BITJsonCanonicalizer",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable"),
        .product(name: "Factory", package: "Factory"),
      ]),
    .testTarget(
      name: "BITJsonCanonicalizerTests",
      dependencies: ["BITJsonCanonicalizer"],
      resources: [.process("Resources")]),
  ])
