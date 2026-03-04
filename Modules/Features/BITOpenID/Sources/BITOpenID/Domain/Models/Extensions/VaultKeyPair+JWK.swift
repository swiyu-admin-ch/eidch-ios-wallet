import BITCrypto
import BITVault
import JOSESwift

extension BITCrypto.JWK {

  init(from keyPair: VaultKeyPair) throws {
    guard let publicKey = keyPair.publicKey else {
      throw JWK.JWKError.invalidSecKey
    }

    let ecPublicKey = try ECPublicKey(publicKey: publicKey)

    self.init(
      kty: ecPublicKey.keyType.rawValue,
      kid: keyPair.identifier,
      crv: ecPublicKey.crv.rawValue,
      x: ecPublicKey.x,
      y: ecPublicKey.y,
      alg: keyPair.algorithm.rawValue)
  }
}
