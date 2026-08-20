import BITCrypto
import BITVault
import Spyable

// MARK: - JWKGeneratorProtocol

@Spyable
public protocol JWKGeneratorProtocol {
  func callAsFunction(from keyPair: VaultKeyPair) throws -> BITCrypto.JWK
}

// MARK: - JWKGenerator

struct JWKGenerator: JWKGeneratorProtocol {

  func callAsFunction(from keyPair: VaultKeyPair) throws -> BITCrypto.JWK {
    guard let publicKey = keyPair.publicKey else {
      throw JWK.JWKError.invalidSecKey
    }

    return try JWK(from: publicKey)
  }
}
