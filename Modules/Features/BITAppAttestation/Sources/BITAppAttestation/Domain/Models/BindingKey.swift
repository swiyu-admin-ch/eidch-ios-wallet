import BITCrypto

public struct BindingKey: Codable, Equatable {

  public init(jwk: JWK) {
    self.jwk = jwk
  }

  let jwk: JWK
}
