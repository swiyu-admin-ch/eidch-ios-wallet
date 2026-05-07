// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITClaimsPathPointer",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITClaimsPathPointer",
      targets: ["BITClaimsPathPointer"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITClaimsPathPointer",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
    .testTarget(
      name: "BITClaimsPathPointerTests",
      dependencies: ["BITClaimsPathPointer"],
      resources: [.process("Resources")]),
  ])
