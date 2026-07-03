import BITCrypto
import DidResolver
import Factory
import Foundation
import Spyable

// MARK: - DidResolverHelperProtocol

@Spyable
public protocol DidResolverHelperProtocol {
  func getDid(from kid: String?) throws -> String
  func getJWK(from kid: String?) async throws -> JWK
  func getURL(from did: String) throws -> URL
}

// MARK: - DidResolverHelperError

enum DidResolverHelperError: String, Error {
  case invalidKeyIdentifier
  case invalidDidUrl
  case didDocumentDeactivated
  case jwkError
}

// MARK: - DidResolverHelper

struct DidResolverHelper: DidResolverHelperProtocol {

  // MARK: Internal

  func getDid(from kid: String?) throws -> String {
    guard let kid else { throw DidResolverHelperError.invalidKeyIdentifier }
    return try getDidFromAbsoluteKid(absoluteKid: kid).asString()
  }

  func getJWK(from kid: String?) async throws -> JWK {
    guard let kid else { throw DidResolverHelperError.invalidKeyIdentifier }

    let did = try getDidFromAbsoluteKid(absoluteKid: kid)
    let didDocument = try await resolve(did: did)

    if didDocument.getDeactivated() {
      throw DidResolverHelperError.didDocumentDeactivated
    }

    guard
      let didJwk = try? didDocument.getKeyByMethodId(keyId: kid),
      let jwk = JWK(from: didJwk) else
    {
      throw DidResolverHelperError.jwkError
    }
    return jwk
  }

  func getURL(from did: String) throws -> URL {
    let did = try Did(did: did)
    guard let url = URL(string: did.getHttpsUrl()) else {
      throw DidResolverHelperError.invalidDidUrl
    }
    return url
  }

  // MARK: Private

  @Injected(\.didResolverRepository) private var didResolverRepository: DidResolverRepositoryProtocol

  private func resolve(did: Did) async throws -> DidDoc {
    guard let url = URL(string: did.getHttpsUrl()) else { throw DidResolverHelperError.invalidDidUrl }
    let didLog = try await didResolverRepository.fetchDidLog(from: url)
    return try did.resolveAll(didLog: didLog).getDidDoc()
  }

}

extension JWK {

  fileprivate init?(from jwk: Jwk) {
    guard let x = jwk.x, let y = jwk.y, let crv = jwk.crv, let kty = jwk.kty else {
      return nil
    }

    self.init(kty: kty, kid: jwk.kid, crv: crv, x: x, y: y)
  }
}
