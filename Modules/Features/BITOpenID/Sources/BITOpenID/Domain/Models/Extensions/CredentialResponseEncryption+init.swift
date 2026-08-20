extension CredentialResponseEncryption {

  public init(from context: CredentialEncryptionContext) throws {
    try self.init(
      keyPair: context.responseKeyPair,
      enc: context.credentialResponseEncryptionAlgorithm.rawValue,
      zip: context.credentialResponseEncryptionZipValue?.rawValue)
  }
}
