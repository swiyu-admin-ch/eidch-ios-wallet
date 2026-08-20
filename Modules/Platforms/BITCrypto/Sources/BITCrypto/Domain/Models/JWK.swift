import Foundation
import JWSETKit
import Security

// MARK: - JWK

public struct JWK: Codable, Equatable {

  // MARK: Lifecycle

  public init(
    kty: String,
    kid: String? = nil,
    crv: String,
    x: String,
    y: String,
    alg: String? = nil)
  {
    self.kty = kty
    self.kid = kid
    self.crv = crv
    self.x = x
    self.y = y
    self.alg = alg
  }

  public init(from secKey: SecKey) throws {
    do {
      let data = try secKey.publicKey.exportKey(format: .jwk)
      self = try JSONDecoder().decode(Self.self, from: data)
    } catch {
      throw JWKError.invalidSecKey
    }
  }

  // MARK: Public

  public enum JWKError: Error {
    case invalidSecKey
  }

  public let crv: String
  public let x: String
  public let y: String
  public let alg: String?
  public let kid: String?
  public let kty: String

}

extension JWK {
  public func jsonWebKey() throws -> any JSONWebKey {
    let data = try JSONEncoder().encode(self)
    return try AnyJSONWebKey.deserialize(data, format: .jwk)
  }
}
