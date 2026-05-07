import BITCrypto
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialEncryptionContextGeneratorProtocol

@Spyable
public protocol CredentialEncryptionContextGeneratorProtocol {
  func callAsFunction(for metadata: CredentialIssuerMetadata) throws -> CredentialEncryptionContext?
}

// MARK: - CredentialEncryptionContextGenerator

struct CredentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(for metadata: CredentialIssuerMetadata) throws -> CredentialEncryptionContext? {
    guard let requestEncryption = metadata.credentialRequestEncryption else { return nil }
    try credentialEncryptionValidator.validate(metadata)

    var responseKeyPair: VaultKeyPair?
    if let responseEncryption = metadata.credentialResponseEncryption {
      responseKeyPair = try keyRepository.create(using: responseEncryption)
    }

    guard
      let issuerPublicKey = requestEncryption.jwks.keys.first,
      let credentialRequestEncryptionAlgorithm = requestEncryption.supportedEncryptionAlgorithms.first else { return nil }

    return CredentialEncryptionContext(
      issuerPublicKey: issuerPublicKey,
      credentialRequestEncryptionAlgorithm: credentialRequestEncryptionAlgorithm,
      credentialRequestEncryptionZipValue: requestEncryption.supportedZipValues?.first,
      responseKeyPair: responseKeyPair,
      credentialResponseEncryptionAlgorithm: metadata.credentialResponseEncryption?.supportedEncryptionAlgorithms.first,
      credentialResponseEncryptionZipValue: metadata.credentialResponseEncryption?.supportedZipValues?.first)
  }

  // MARK: Private

  @Injected(\.credentialEncryptionValidator) private var credentialEncryptionValidator: CredentialEncryptionValidatorProtocol
  @Injected(\.credentialResponseEncryptionKeyRepository) private var keyRepository: CredentialResponseEncryptionKeyRepositoryProtocol
}
