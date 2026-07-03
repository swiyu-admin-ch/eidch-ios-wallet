// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#warning("Hosted on S3 for now until BIT infrastructure can build and host the XCFramework. Binary built from https://github.com/admin-ch-ssi/PERA_swiyu_shared_kmp")

let package = Package(
  name: "BITSwiyuSharedKMP",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "BITSwiyuSharedKMP",
      targets: ["BITSwiyuSharedKMP"]),
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "BITSwiyuSharedKMP",
      // Hosted on S3 for now until BIT infrastructure can build and host the XCFramework.
      // Binary built from https://github.com/admin-ch-ssi/PERA_swiyu_shared_kmp
      url: "https://ubique-ios-spm.s3.eu-central-2.amazonaws.com/BITSwiyuSharedKMP/0.1.20/BITSwiyuSharedKMP.xcframework.zip",
      checksum: "b9eca281ffa696221f781d008a00e1dbe17befeb3eb223dfdb8ba8b917c7eb2c"),
  ])
