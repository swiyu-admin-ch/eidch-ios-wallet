// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import BITTheming
import Foundation

// MARK: - Lotties

enum Lotties {
  static let confirmIdentity = LottieView(animationFile: "confirm-identity-light", darkModeFile: "confirm-identity-dark", in: BundleToken.bundle)
  static let docRecordAnimation = LottieView(animationFile: "doc_record_animation", in: BundleToken.bundle)
  static let faceRecordAnimation = LottieView(animationFile: "face_record_animation", in: BundleToken.bundle)
  static let readPassNfc = LottieView(animationFile: "read-pass-nfc-light", darkModeFile: "read-pass-nfc-dark", in: BundleToken.bundle)
  static let recordDoc = LottieView(animationFile: "record-doc-light", darkModeFile: "record-doc-dark", in: BundleToken.bundle)
  static let recordPass = LottieView(animationFile: "record-pass-light", darkModeFile: "record-pass-dark", in: BundleToken.bundle)
  static let scanDocBack = LottieView(animationFile: "scan-doc-back-light", darkModeFile: "scan-doc-back-dark", in: BundleToken.bundle)
  static let scanDocFront = LottieView(animationFile: "scan-doc-front-light", darkModeFile: "scan-doc-front-dark", in: BundleToken.bundle)
  static let scanDocPass1 = LottieView(animationFile: "scan-doc-pass-1-light", darkModeFile: "scan-doc-pass-1-dark", in: BundleToken.bundle)
  static let scanDocPass2 = LottieView(animationFile: "scan-doc-pass-2-light", darkModeFile: "scan-doc-pass-2-dark", in: BundleToken.bundle)
}

// MARK: - BundleToken

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

// swiftlint:enable convenience_type
