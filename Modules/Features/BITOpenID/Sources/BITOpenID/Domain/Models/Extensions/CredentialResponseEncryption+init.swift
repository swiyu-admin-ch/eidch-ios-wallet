extension CredentialResponseEncryption {

  // MARK: Lifecycle

  init?(from context: CredentialEncryptionContext) throws {
    guard let keyPair = context.responseKeyPair else { return nil }

    guard let encryptionAlgorithm = context.credentialResponseEncryptionAlgorithm else {
      throw CredentialResponseEncryptionError.missingEncryptionAlgorithm
    }

    try self.init(
      keyPair: keyPair,
      enc: encryptionAlgorithm.rawValue,
      zip: context.credentialResponseEncryptionZipValue?.rawValue)
  }

  // MARK: Internal

  enum CredentialResponseEncryptionError: Error {
    case missingEncryptionAlgorithm
  }

}
