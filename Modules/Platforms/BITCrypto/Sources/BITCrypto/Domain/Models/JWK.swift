import BITCore
import JOSESwift
import Security

public struct JWK: Codable, Equatable {

  // MARK: Lifecycle

  public init(kty: String, kid: String? = nil, crv: String, x: String, y: String) {
    self.kty = kty
    self.kid = kid
    self.crv = crv
    self.x = x
    self.y = y
  }

  public init(from secKey: SecKey) throws {
    guard let ecPublicKey = try? ECPublicKey(publicKey: secKey) else {
      throw JWKError.invalidSecKey
    }

    self = JWK(kty: ecPublicKey.keyType.rawValue, kid: ecPublicKey["kid"], crv: ecPublicKey.crv.rawValue, x: ecPublicKey.x, y: ecPublicKey.y)
  }

  // MARK: Public

  public let crv: String
  public let x: String
  public let y: String

  // MARK: Internal

  enum JWKError: Error {
    case invalidSecKey
  }

  // MARK: Private

  private let kid: String?
  private let kty: String
}
