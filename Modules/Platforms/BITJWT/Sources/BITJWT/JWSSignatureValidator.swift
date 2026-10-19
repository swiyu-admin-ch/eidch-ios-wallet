import BITCrypto
import Factory
import Foundation
import JWSETKit

// MARK: - JWSSignatureValidatorProtocol

public protocol JWSSignatureValidatorProtocol: Sendable {
  func validate(_ jws: JWS<some JWT>) async throws
  func validate(_ jws: JWS<some JWT>, with jwk: BITCrypto.JWK) throws
  func validate(_ detachedJWS: DetachedJWS, payload: Data) async throws
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

  public func validate(_ detachedJWS: DetachedJWS, payload: Data) async throws {
    let jwk = try await getJWK(from: detachedJWS.header.keyIdentifier)
    guard validateDetachedJwsSignature(for: detachedJWS, over: payload, jwk: jwk) else {
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
    guard let signedJws = try? JSONWebSignaturePlain(from: jws.rawJWS) else {
      return false
    }
    return isSignatureValid(of: signedJws, jwk: jwk)
  }

  private func validateDetachedJwsSignature(for detachedJWS: DetachedJWS, over payload: Data, jwk: BITCrypto.JWK) -> Bool {
    guard
      var signedJws = try? JSONWebSignaturePlain(from: detachedJWS.rawJWS),
      let detachedPayload = try? ProtectedDataWebContainer(encoded: payload)
    else {
      return false
    }
    signedJws.payload = detachedPayload
    return isSignatureValid(of: signedJws, jwk: jwk)
  }

  private func isSignatureValid(of jws: JSONWebSignaturePlain, jwk: BITCrypto.JWK) -> Bool {
    do {
      guard let validatingKey = try jwk.jsonWebKey() as? any JSONWebValidatingKey else {
        return false
      }
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
