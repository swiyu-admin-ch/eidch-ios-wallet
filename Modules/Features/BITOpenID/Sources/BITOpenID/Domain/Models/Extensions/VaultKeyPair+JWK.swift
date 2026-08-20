import BITCrypto
import BITVault

extension BITCrypto.JWK {

  init(from keyPair: VaultKeyPair) throws {
    guard let publicKey = keyPair.publicKey else {
      throw JWK.JWKError.invalidSecKey
    }

    let jwk = try JWK(from: publicKey)

    self.init(
      kty: jwk.kty,
      kid: keyPair.identifier,
      crv: jwk.crv,
      x: jwk.x,
      y: jwk.y,
      alg: keyPair.algorithm.rawValue)
  }
}
