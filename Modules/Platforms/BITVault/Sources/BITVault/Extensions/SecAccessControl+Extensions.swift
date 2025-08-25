import Foundation

extension SecAccessControl {

  static let defaultProtection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  static let defaultAccesControlFlags: SecAccessControlCreateFlags = [.privateKeyUsage]

  static func create(accessControlFlags: SecAccessControlCreateFlags = SecAccessControl.defaultAccesControlFlags, protection: CFString = SecAccessControl.defaultProtection) throws -> SecAccessControl {
    var accessControlError: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, accessControlFlags, &accessControlError) else {
      if let error = accessControlError?.takeRetainedValue() {
        throw VaultError.keyGenerationError(reason: "Access control creation failed with error: \(error)")
      }
      throw VaultError.keyGenerationError(reason: "Unknown error during access control creation.")
    }
    return accessControl
  }
}
