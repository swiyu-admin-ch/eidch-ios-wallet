import BITCrypto
import BITVault

// MARK: - KeyAttestationRequestBody

public struct KeyAttestationRequestBody: Codable, Equatable {

  // MARK: Lifecycle

  public init(bindingKey: BindingKey) {
    self.bindingKey = bindingKey
  }

  public init(keyPair: VaultKeyPair) throws {
    guard let publicKey = keyPair.publicKey, let jwk = try? JWK(from: publicKey) else {
      throw KeyAttestationRequestBodyError.invalidBindingKey
    }

    bindingKey = BindingKey(jwk: jwk)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case bindingKey = "cnf"
  }

  let bindingKey: BindingKey

}

// MARK: - KeyAttestationRequestBodyError

public enum KeyAttestationRequestBodyError: Error {
  case invalidBindingKey
}
