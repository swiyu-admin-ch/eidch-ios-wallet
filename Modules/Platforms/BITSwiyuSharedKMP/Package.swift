// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#warning("Hosted on S3 for now until BIT infrastructure can build and host the XCFramework. Binary built from https://github.com/admin-ch-ssi/PERA_swiyu_shared_kmp")

let package = Package(
  name: "BITSwiyuSharedKMP",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
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
      url: "https://ubique-ios-spm.s3.eu-central-2.amazonaws.com/BITSwiyuSharedKMP/0.1.6/BITSwiyuSharedKMP.xcframework.zip",
      checksum: "172506ff8ead144c70b15280e01fe450e1f520f8a03f02348e6d65b8b327a2cf"),
  ])
