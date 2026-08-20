// MARK: - JWTAlgorithm

public enum JWTAlgorithm: String, Decodable {
  case ES256
  case ES384
  case ES512
  case Ed25519
}
