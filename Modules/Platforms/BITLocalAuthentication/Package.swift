// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITLocalAuthentication",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITLocalAuthentication",
      targets: ["BITLocalAuthentication"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITLocalAuthentication",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable"),
      ]),
    .target(
      name: "BITLocalAuthenticationMocks",
      dependencies: [
        "BITLocalAuthentication",
      ]),
    .testTarget(
      name: "BITLocalAuthenticationTests",
      dependencies: [
        "BITLocalAuthentication",
        "BITLocalAuthenticationMocks",
      ]),
  ])
