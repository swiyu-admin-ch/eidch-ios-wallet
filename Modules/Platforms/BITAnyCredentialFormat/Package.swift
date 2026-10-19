// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITAnyCredentialFormat",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITAnyCredentialFormat",
      targets: ["BITAnyCredentialFormat"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITCore"),
    .package(path: "../../Platforms/BITSdJWT"),
    .package(url: "https://github.com/Matejkob/swift-spyable", exact: "0.8.0"),
  ],
  targets: [
    .target(
      name: "BITAnyCredentialFormat",
      dependencies: [
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "BITSdJWT", package: "BITSdJWT"),
        .product(name: "Spyable", package: "swift-spyable"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BITAnyCredentialFormatTests",
      dependencies: ["BITAnyCredentialFormat"]),
  ])
