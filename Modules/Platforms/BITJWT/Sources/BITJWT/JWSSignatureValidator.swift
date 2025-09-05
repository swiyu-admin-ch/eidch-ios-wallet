import BITCrypto
import Factory
import Foundation
import JOSESwift

// MARK: - JWSSignatureValidatorProtocol

public protocol JWSSignatureValidatorProtocol {
  func validate(_ jws: JWS<some Codable & Equatable>, issuerDid: String) async throws -> Bool
}

// MARK: - JWSSignatureValidatorError

public enum JWSSignatureValidatorError: Error {
  case cannotResolveDid(_ error: Error)
  case invalidKeyIdentifier
}

// MARK: - JWSSignatureValidator

public struct JWSSignatureValidator: JWSSignatureValidatorProtocol {

  // MARK: Public

  public func validate(_ jws: JWS<some Codable & Equatable>, issuerDid: String) async throws -> Bool {
    let jwks = try await getJwks(from: issuerDid, keyIdentifier: jws.header.keyIdentifier)
    return jwks.contains { validateJwtSignature(for: jws, jwk: $0) }
  }

  // MARK: Private

  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func getJwks(from did: String, keyIdentifier: String?) async throws -> [BITCrypto.JWK] {
    do {
      return try await didResolverHelper.getJWKS(from: did, keyIdentifier: keyIdentifier)
    } catch DidResolverHelperError.didDocumentDeactivated {
      return []
    } catch {
      throw JWSSignatureValidatorError.cannotResolveDid(error)
    }
  }

  private func validateJwtSignature(for jws: JWS<some Codable & Equatable>, jwk: BITCrypto.JWK) -> Bool {
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
    return Verifier(verifyingAlgorithm: signatureAlgorithm, key: secKey)
  }
}
