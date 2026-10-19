import BITCrypto

public struct BindingKey: Codable, Equatable, Sendable {

  public init(jwk: JWK) {
    self.jwk = jwk
  }

  let jwk: JWK
}
