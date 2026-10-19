// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "BITL10n",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
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
