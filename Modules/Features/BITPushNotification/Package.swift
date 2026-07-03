// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITPushNotification",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITPushNotification",
      targets: ["BITPushNotification"]),
  ],
  dependencies: [
    .package(path: "../BITAppAttestation"),
    .package(path: "../BITAppAuth"),
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITTheming"),
    .package(path: "../../Platforms/BITNetworking"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITPushNotification",
      dependencies: [
        .product(name: "BITAppAttestation", package: "BITAppAttestation"),
        .product(name: "BITAppAuth", package: "BITAppAuth"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITTheming", package: "BITTheming"),
        .product(name: "BITNetworking", package: "BITNetworking"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITPushNotificationTests",
      dependencies: [
        "BITPushNotification",
        .product(name: "BITTestingCore", package: "BITCore"),
      ]),
  ])
