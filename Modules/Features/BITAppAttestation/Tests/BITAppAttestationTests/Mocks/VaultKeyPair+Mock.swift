// swiftlint: disable force_unwrapping
import Foundation
import Security
@testable import BITVault

extension VaultKeyPair.Mock {
  static let attestedKey = VaultKeyPair(
    identifier: UUID().uuidString,
    privateKey: SecKeyCreateWithData(
      Data(base64Encoded: "BNfMBy3iIFvcFTelQ9U8YKasti7M2JDH+ifJ41QIm74T+V4dS4UaLMgP/4fY4j8ir7cl1TXlFdAgcx55o7TkcSA=")! as CFData,
      [
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits as String: 256,
      ] as CFDictionary,
      nil)!,
    algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
}

// swiftlint: enable force_unwrapping
