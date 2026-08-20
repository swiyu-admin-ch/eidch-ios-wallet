import BITCrypto
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialEncryptionContextGeneratorError

enum CredentialEncryptionContextGeneratorError: Error {
  case noSupportedEncryptionAlgorithm
  case missingIssuerEncryptionKeys
  case noSuitableEncryptionKey
}

// MARK: - CredentialEncryptionContextGeneratorProtocol

@Spyable
public protocol CredentialEncryptionContextGeneratorProtocol {
  func callAsFunction(for metadata: CredentialIssuerMetadata) throws -> CredentialEncryptionContext
}

// MARK: - CredentialEncryptionContextGenerator

struct CredentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(for metadata: CredentialIssuerMetadata) throws -> CredentialEncryptionContext {
    guard
      let requestEncryptionAlgorithm = metadata.credentialRequestEncryption.supportedEncryptionAlgorithms.first,
      let responseEncryptionAlgorithm = metadata.credentialResponseEncryption.supportedEncryptionAlgorithms.first
    else { throw CredentialEncryptionContextGeneratorError.noSupportedEncryptionAlgorithm }

    guard metadata.credentialRequestEncryption.jwks.keys.isEmpty == false else {
      throw CredentialEncryptionContextGeneratorError.missingIssuerEncryptionKeys
    }

    guard let publicKey = metadata.credentialRequestEncryption.jwks.keys.first(where: isSupported) else {
      throw CredentialEncryptionContextGeneratorError.noSuitableEncryptionKey
    }

    return try CredentialEncryptionContext(
      issuerPublicKey: publicKey,
      credentialRequestEncryptionAlgorithm: requestEncryptionAlgorithm,
      credentialRequestEncryptionZipValue: metadata.credentialRequestEncryption.supportedZipValues?.first,
      responseKeyPair: keyRepository.create(using: metadata.credentialResponseEncryption),
      credentialResponseEncryptionAlgorithm: responseEncryptionAlgorithm,
      credentialResponseEncryptionZipValue: metadata.credentialResponseEncryption.supportedZipValues?.first)
  }

  // MARK: Private

  @Injected(\.credentialResponseEncryptionKeyRepository) private var keyRepository
  @Injected(\.encryptionSupportedCurves) private var supportedCurves: [String]

  private func isSupported(_ jwk: JWK) -> Bool {
    guard
      let alg = jwk.alg,
      supportedCurves.contains(jwk.crv)
    else {
      return false
    }

    return KeyManagementAlgorithm(rawValue: alg) != nil
  }
}
