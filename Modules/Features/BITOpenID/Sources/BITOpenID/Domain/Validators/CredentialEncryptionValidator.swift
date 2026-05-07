import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - CredentialEncryptionError

enum CredentialEncryptionError: Error {
  case missingRequestEncryption
  case missingIssuerEncryptionKeys
  case unsupportedJwkCurve
  case unsupportedKeyManagementAlgorithm
}

// MARK: - CredentialEncryptionValidatorProtocol

@Spyable
protocol CredentialEncryptionValidatorProtocol {
  func validate(_ metadata: CredentialIssuerMetadata) throws
}

// MARK: - CredentialEncryptionValidator

struct CredentialEncryptionValidator: CredentialEncryptionValidatorProtocol {

  // MARK: Internal

  func validate(_ metadata: CredentialIssuerMetadata) throws {
    if metadata.credentialResponseEncryption != nil && metadata.credentialRequestEncryption == nil {
      throw CredentialEncryptionError.missingRequestEncryption
    }

    if let credentialRequestEncryption = metadata.credentialRequestEncryption {
      try validateRequestEncryption(credentialRequestEncryption)
    }
  }

  // MARK: Private

  @Injected(\.encryptionSupportedCurves) private var supportedRequestCurves: [String]

  private func validateRequestEncryption(_ requestEncryption: CredentialIssuerMetadata.CredentialRequestEncryption) throws {

    guard requestEncryption.jwks.keys.isEmpty == false else {
      throw CredentialEncryptionError.missingIssuerEncryptionKeys
    }

    guard requestEncryption.jwks.keys.contains(where: { supportedRequestCurves.contains($0.crv) }) else {
      throw CredentialEncryptionError.unsupportedJwkCurve
    }

    guard
      requestEncryption.jwks.keys.contains(where: { jwk in
        guard let alg = jwk.alg else { return false }
        return KeyManagementAlgorithm(rawValue: alg) != nil
      }) else
    {
      throw CredentialEncryptionError.unsupportedKeyManagementAlgorithm
    }
  }
}
