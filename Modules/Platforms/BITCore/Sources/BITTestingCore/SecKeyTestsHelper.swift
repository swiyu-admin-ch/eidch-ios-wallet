// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
#if DEBUG
import Foundation

struct SecKeyTestsHelper {

  // MARK: Internal

  static func createStaticPrivateKey() -> SecKey {
    let keyData = Data(base64Encoded: privateKey)!

    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
      kSecAttrKeySizeInBits as String: 256,
    ]

    var error: Unmanaged<CFError>?
    guard let key = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
      fatalError("EC private key creation from data failed: \(error!.takeRetainedValue())")
    }
    return key
  }

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

  // MARK: Private

  static private let privateKey = """
  BKjC5TkeV1fPglkgjfUtx0Dnz5mDIZGcStRSTm4pM2HvvmN1+2KgPIAV3VuraXZhAuhr6rr27HL3mPLSaTo+HdekOlvM63YI+W7VTBeLw3s3w1nlfXtNNaz9tmELMV+ptg==
  """

}
#endif
