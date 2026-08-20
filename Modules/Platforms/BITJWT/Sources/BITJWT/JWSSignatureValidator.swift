import BITCrypto
import Factory
import Foundation
import JWSETKit

// MARK: - JWSSignatureValidatorProtocol

public protocol JWSSignatureValidatorProtocol {
  func validate(_ jws: JWS<some JWT>) async throws
  func validate(_ jws: JWS<some JWT>, with jwk: BITCrypto.JWK) throws
}

// MARK: - JWSSignatureValidatorError

public enum JWSSignatureValidatorError: Error {
  case cannotResolveDid(_ error: Error)
  case invalidKeyIdentifier
  case invalidSignature
}

// MARK: - JWSSignatureValidator

public struct JWSSignatureValidator: JWSSignatureValidatorProtocol {

  // MARK: Public

  public func validate(_ jws: JWS<some JWT>) async throws {
    let jwk = try await getJWK(from: jws.header.keyIdentifier)
    guard validateJwtSignature(for: jws, jwk: jwk) else {
      throw JWSSignatureValidatorError.invalidSignature
    }
  }

  public func validate(_ jws: JWS<some JWT>, with jwk: BITCrypto.JWK) throws {
    guard validateJwtSignature(for: jws, jwk: jwk) else {
      throw JWSSignatureValidatorError.invalidSignature
    }
  }

  // MARK: Private

  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func getJWK(from kid: String?) async throws -> BITCrypto.JWK {
    do {
      return try await didResolverHelper.getJWK(from: kid)
    } catch {
      throw JWSSignatureValidatorError.cannotResolveDid(error)
    }
  }

  private func validateJwtSignature(for jws: JWS<some JWT>, jwk: BITCrypto.JWK) -> Bool {
    do {
      let validatingKey = try jwk.jsonWebKey()
      guard let validatingKey = validatingKey as? any JSONWebValidatingKey else {
        return false
      }
      let jws = try JSONWebSignaturePlain(from: jws.rawJWS)
      try jws.verifySignature(using: [validatingKey])
      return true
    } catch {
      return false
    }
  }
}

// MARK: - JWSSignatureValidatorError + Equatable

extension JWSSignatureValidatorError: Equatable {
  public static func == (lhs: JWSSignatureValidatorError, rhs: JWSSignatureValidatorError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotResolveDid, .cannotResolveDid):
      true
    case (.invalidKeyIdentifier, .invalidKeyIdentifier):
      true
    case (.invalidSignature, .invalidSignature):
      true
    default:
      false
    }
  }
}
