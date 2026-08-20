import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - AuthorizationResponseEncryptionGeneratorError

enum AuthorizationResponseEncryptionGeneratorError: Error {
  case missingClientData
  case noSuitableEncryptionKey
  case unsupportedEncryptionValue
}

// MARK: - AuthorizationResponseEncryptionGeneratorProtocol

@Spyable
public protocol AuthorizationResponseEncryptionGeneratorProtocol {
  func callAsFunction(for clientMetadata: ClientMetadata?) throws -> AuthorizationResponseEncryption
}

// MARK: - AuthorizationResponseEncryptionGenerator

struct AuthorizationResponseEncryptionGenerator: AuthorizationResponseEncryptionGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(for clientMetadata: ClientMetadata?) throws -> AuthorizationResponseEncryption {
    guard let clientMetadata else { throw AuthorizationResponseEncryptionGeneratorError.missingClientData }
    let algorithms = clientMetadata.encryptedResponseEncValuesSupported?.compactMap { EncryptionAlgorithm(rawValue: $0) }
    guard let algorithm = algorithms?.first else {
      throw AuthorizationResponseEncryptionGeneratorError.unsupportedEncryptionValue
    }

    guard let jwk = clientMetadata.jwks?.keys.first(where: isSupported) else {
      throw AuthorizationResponseEncryptionGeneratorError.noSuitableEncryptionKey
    }
    return AuthorizationResponseEncryption(jwk: jwk, algorithm: algorithm)
  }

  // MARK: Private

  @Injected(\.encryptionSupportedCurves) private var encryptionSupportedCurves

  private func isSupported(_ jwk: JWK) -> Bool {
    guard
      let alg = jwk.alg,
      encryptionSupportedCurves.contains(jwk.crv)
    else {
      return false
    }

    return KeyManagementAlgorithm(rawValue: alg) != nil
  }
}
