import BITVault
import Foundation

// MARK: - MockKeyManager

struct MockKeyManager: KeyManagerProtocol {
  func generateKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, options: VaultOption, query: Query?) throws -> SecKey {
    SecKeyTestsHelper.createPrivateKey(size: algorithm.size)
  }

  func deleteKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm) throws {

  }

  func getPublicKey(for privateKey: SecKey) throws -> SecKey {
    SecKeyTestsHelper.createPrivateKey()
  }

  func getPublicKey(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> SecKey {
    SecKeyTestsHelper.createPrivateKey(size: algorithm.size)
  }

  func getPrivateKey(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> SecKey {
    SecKeyTestsHelper.createPrivateKey(size: algorithm.size)
  }
}

// MARK: MockKeyManager.SecKeyTestsHelper

extension MockKeyManager {
  private struct SecKeyTestsHelper {

    static func createPrivateKey(type: String = kSecAttrKeyTypeECSECPrimeRandom as String, size: Int = 521) -> SecKey {
      let attributes: [String: Any] = [
        kSecAttrKeyType as String: type,
        kSecAttrKeySizeInBits as String: size,
        kSecPrivateKeyAttrs as String: [
          kSecAttrIsPermanent as String: false,
          kSecAttrApplicationTag as String: UUID().uuidString,
        ],
      ]

      var error: Unmanaged<CFError>?
      guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        fatalError("Can not create Private Key: \(error.debugDescription)")
      }
      return privateKey
    }

    static func getPublicKey(for privateKey: SecKey) -> SecKey {
      guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
        fatalError("Can not get the Public Key")
      }
      return publicKey
    }

    static func createAccessControl(accessControlFlags: SecAccessControlCreateFlags, protection: CFString) -> SecAccessControl {
      var accessControlError: Unmanaged<CFError>?
      guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, accessControlFlags, &accessControlError) else {
        if let error = accessControlError?.takeRetainedValue() {
          fatalError("Access control creation failed with error: \(error)")
        } else {
          fatalError("Unknown error during access control creation.")
        }
      }
      return accessControl
    }
  }
}
