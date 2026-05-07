// swift-tools-version: 5.10.1

import PackageDescription

let package = Package(
  name: "BITTheming",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITTheming",
      targets: ["BITTheming"]),
  ],
  dependencies: [
    .package(path: "../../Platforms/BITL10n"),
    .package(path: "../../Platforms/BITCore"),
    .package(url: "https://github.com/siteline/swiftui-introspect", exact: "1.3.0"),
    .package(url: "https://github.com/airbnb/lottie-ios", exact: "4.5.1"),
    .package(url: "https://github.com/hmlongco/Navigator", exact: "2.0.2"),
    .package(url: "https://github.com/exyte/PopupView", exact: "3.1.4"), // 4.1.11 available
  ],
  targets: [
    .target(
      name: "BITTheming",
      dependencies: [
        .product(name: "BITL10n", package: "BITL10n"),
        .product(name: "BITCore", package: "BITCore"),
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        .product(name: "Lottie", package: "lottie-ios"),
        .product(name: "PopupView", package: "PopupView"),
        .product(name: "NavigatorUI", package: "Navigator"),
      ],
      resources: [
        .process("Resources"),
      ]),
  ])
