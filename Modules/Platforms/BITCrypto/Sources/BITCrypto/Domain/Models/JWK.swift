import BITCore
import JOSESwift
import Security

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
    guard let ecPublicKey = try? ECPublicKey(publicKey: secKey) else {
      throw JWKError.invalidSecKey
    }

    self = JWK(
      kty: ecPublicKey.keyType.rawValue,
      kid: ecPublicKey["kid"],
      crv: ecPublicKey.crv.rawValue,
      x: ecPublicKey.x,
      y: ecPublicKey.y)
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
