import BITCrypto
import BITVault

public struct CredentialEncryptionContext: Equatable, Sendable {

  public let issuerPublicKey: JWK
  public let credentialRequestEncryptionAlgorithm: EncryptionAlgorithm
  public let credentialRequestEncryptionZipValue: CompressionAlgorithm?
  public let responseKeyPair: VaultKeyPair
  public let credentialResponseEncryptionAlgorithm: EncryptionAlgorithm
  public let credentialResponseEncryptionZipValue: CompressionAlgorithm?
}
