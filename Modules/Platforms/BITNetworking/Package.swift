// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITNetworking",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITNetworking",
      targets: ["BITNetworking"]),
  ],
  dependencies: [
    .package(path: "../BITCore"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.2.0"),
  ],
  targets: [
    .target(
      name: "BITNetworking",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "Moya", package: "Moya"),
        .product(name: "Factory", package: "Factory"),
      ]),
    .testTarget(
      name: "BITNetworkingTests",
      dependencies: ["BITNetworking"]),
  ])
