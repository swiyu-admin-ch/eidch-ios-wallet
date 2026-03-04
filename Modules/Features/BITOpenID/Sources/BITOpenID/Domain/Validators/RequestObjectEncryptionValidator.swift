import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - RequestObjectEncryptionError

enum RequestObjectEncryptionError: Error {
  case missingClientMetadata
  case missingEncryptionKeys
  case unsupportedJwkCurve
  case unsupportedKeyManagementAlgorithm
  case unsupportedEncryptionValue
}

// MARK: - RequestObjectEncryptionValidatorProtocol

@Spyable
protocol RequestObjectEncryptionValidatorProtocol {
  func validate(_ requestObject: RequestObject) throws
}

// MARK: - RequestObjectEncryptionValidator

struct RequestObjectEncryptionValidator: RequestObjectEncryptionValidatorProtocol {

  // MARK: Internal

  func validate(_ requestObject: RequestObject) throws {
    guard requestObject.responseMode == .directPostJWT else { return }

    guard let clientMetadata = requestObject.clientMetadata else {
      throw RequestObjectEncryptionError.missingClientMetadata
    }

    if let encValuesSupported = clientMetadata.encryptedResponseEncValuesSupported {
      guard encValuesSupported.contains(where: { EncryptionAlgorithm(rawValue: $0) != nil }) else {
        throw RequestObjectEncryptionError.unsupportedEncryptionValue
      }
    }

    guard let jwks = clientMetadata.jwks, jwks.keys.isEmpty == false else {
      throw RequestObjectEncryptionError.missingEncryptionKeys
    }

    guard
      jwks.keys.contains(where: { jwk in
        guard let alg = jwk.alg else { return false }
        return KeyManagementAlgorithm(rawValue: alg) != nil
      }) else
    {
      throw RequestObjectEncryptionError.unsupportedKeyManagementAlgorithm
    }

    guard
      jwks.keys.contains(where: { jwk in
        encryptionSupportedCurves.contains(jwk.crv)
      }) else
    {
      throw RequestObjectEncryptionError.unsupportedJwkCurve
    }
  }

  // MARK: Private

  @Injected(\.encryptionSupportedCurves) private var encryptionSupportedCurves
}
