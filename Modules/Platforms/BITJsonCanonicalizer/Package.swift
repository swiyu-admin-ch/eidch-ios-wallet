// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITJsonCanonicalizer",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITJsonCanonicalizer",
      targets: ["BITJsonCanonicalizer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITJsonCanonicalizer",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
    .testTarget(
      name: "BITJsonCanonicalizerTests",
      dependencies: ["BITJsonCanonicalizer"],
      resources: [.process("Resources")]),
  ])
