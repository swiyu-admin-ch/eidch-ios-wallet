// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITLocalAuthentication",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
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
    .testTarget(
      name: "BITLocalAuthenticationTests",
      dependencies: [
        "BITLocalAuthentication",
      ]),
  ])
