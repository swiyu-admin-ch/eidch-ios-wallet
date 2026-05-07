// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITNetworking",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITNetworking",
      targets: ["BITNetworking"]),
  ],
  dependencies: [
    .package(path: "../BITCore"),
    .package(path: "../BITAnalytics"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
  ],
  targets: [
    .target(
      name: "BITNetworking",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITAnalytics", package: "BITAnalytics"),
        .product(name: "Moya", package: "Moya"),
        .product(name: "Factory", package: "Factory"),
      ]),
    .testTarget(
      name: "BITNetworkingTests",
      dependencies: [
        "BITNetworking",
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Moya", package: "Moya"),
      ]),
  ])
