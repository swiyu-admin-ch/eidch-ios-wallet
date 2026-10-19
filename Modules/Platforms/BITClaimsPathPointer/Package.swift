// swift-tools-version: 6.3

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
      dependencies: ["BITClaimsPathPointer"]),
  ])
