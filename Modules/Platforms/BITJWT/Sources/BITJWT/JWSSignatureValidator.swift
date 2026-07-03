import BITCrypto
import Factory
import Foundation
import JOSESwift

// MARK: - JWSSignatureValidatorProtocol

public protocol JWSSignatureValidatorProtocol {
  func validate(_ jws: JWS<some JWT>) async throws
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
      guard let verifier = try createVerifier(for: jwk, algorithm: jws.header.algorithm) else { return false }
      let jws = try JOSESwift.JWS(compactSerialization: jws.rawJWS)
      _ = try jws.validate(using: verifier).payload
      return true
    } catch {
      return false
    }
  }

  private func createVerifier(for jwk: BITCrypto.JWK, algorithm: JWTAlgorithm) throws -> Verifier? {
    guard let secKey = try ECPublicKey.getSecKey(curve: jwk.crv, x: jwk.x, y: jwk.y) else { return nil }
    let signatureAlgorithm = try SignatureAlgorithm(from: algorithm)
    return Verifier(signatureAlgorithm: signatureAlgorithm, key: secKey)
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
