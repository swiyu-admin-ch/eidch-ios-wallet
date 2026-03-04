// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BITL10n",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "BITL10n",
      targets: ["BITL10n"]),
  ],
  targets: [
    .target(
      name: "BITL10n",
      resources: [
        .process("Resources"),
      ]),
  ])
