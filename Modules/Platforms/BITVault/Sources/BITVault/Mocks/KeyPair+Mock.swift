#if DEBUG
import Foundation

extension VaultKeyPair {

  // MARK: Public

  public struct Mock {
    public static let ES256 = VaultKeyPair(
      identifier: UUID().uuidString,
      privateKey: createPrivateKey(size: 256),
      algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM,
      options: .secureEnclave)
    public static let ES512 = VaultKeyPair(
      identifier: UUID().uuidString,
      privateKey: createPrivateKey(size: 521),
      algorithm: .eciesEncryptionStandardVariableIVX963SHA512AESGCM,
      options: .secureEnclave)

    public static func ES256SecureEnclavePermanently(id: UUID) -> VaultKeyPair {
      VaultKeyPair(
        identifier: id.uuidString,
        privateKey: createPrivateKey(size: 256),
        algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM,
        options: .secureEnclavePermanently)
    }

    public static func ES256SavePermanently(id: UUID) -> VaultKeyPair {
      VaultKeyPair(
        identifier: id.uuidString,
        privateKey: createPrivateKey(size: 256),
        algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM,
        options: .savePermanently)
    }

  }

  // MARK: Private

  // swiftlint:disable all
  static private func createPrivateKey(size: Int) -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: size,
    ]

    return SecKeyCreateRandomKey(attributes as CFDictionary, nil)!
  }
  // swiftlint:enable all
}

#endif
