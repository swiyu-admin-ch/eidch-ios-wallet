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
      url: "https://ubique-ios-spm.s3.eu-central-2.amazonaws.com/BITSwiyuSharedKMP/0.1.12/BITSwiyuSharedKMP.xcframework.zip",
      checksum: "263b70f23fb936b9296f836bd73bcae7c717420cfe40fb819e094f0f605cf834"),
  ])
