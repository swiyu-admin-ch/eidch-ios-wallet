import BITCrypto
import DidResolver
import Factory
import Foundation
import Spyable

// MARK: - DidResolverHelperProtocol

@Spyable
protocol DidResolverHelperProtocol {
  func getJWKS(from did: String, keyIdentifier: String?) async throws -> [JWK]
}

// MARK: - DidResolverHelperError

enum DidResolverHelperError: String, Error {
  case invalidDidUrl
  case didDocumentDeactivated
}

// MARK: - DidResolverHelper

struct DidResolverHelper: DidResolverHelperProtocol {

  // MARK: Internal

  func getJWKS(from did: String, keyIdentifier: String?) async throws -> [JWK] {
    let didDocument = try await resolve(didRaw: did)

    if didDocument.getDeactivated() {
      throw DidResolverHelperError.didDocumentDeactivated
    }

    return didDocument.getVerificationMethod()
      .filter({ $0.id == keyIdentifier })
      .compactMap(\.publicKeyJwk)
      .compactMap({ JWK(from: $0) })
  }

  // MARK: Private

  @Injected(\.didResolverRepository) private var didResolverRepository: DidResolverRepositoryProtocol

  private func resolve(didRaw: String) async throws -> DidDoc {
    let did = try Did(didTdw: didRaw)
    guard let url = try URL(string: did.getUrl()) else { throw DidResolverHelperError.invalidDidUrl }
    let didLog = try await didResolverRepository.fetchDidLog(from: url)
    return try did.resolve(didTdwLog: didLog)
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
