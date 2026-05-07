import BITVault

extension VaultAlgorithm {

  // MARK: Lifecycle

  init(_ encryption: CredentialIssuerMetadata.CredentialResponseEncryption) throws {
    // taking the first as of the spec, only one is supported
    switch encryption.supportedAlgorithmValues.first {
    case .ECDH_ES: self = .ecdhP256
    default: throw CredentialResponseEncryptionKeyError.responseEncryptionAlgorithmError
    }
  }

  // MARK: Internal

  enum CredentialResponseEncryptionKeyError: Error {
    case responseEncryptionAlgorithmError
  }

}
