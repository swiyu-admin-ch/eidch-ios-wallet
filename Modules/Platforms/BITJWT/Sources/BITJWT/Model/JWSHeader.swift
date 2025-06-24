import BITCrypto
import Foundation

// MARK: - JWSHeader

/// This class represents the header of a signed JWT (JWS) which is specified by https://www.rfc-editor.org/rfc/rfc7515.html
open class JWSHeader: Equatable {

  // MARK: Lifecycle

  public init(
    algorithm: JWTAlgorithm,
    type: String? = nil,
    keyIdentifier: String? = nil,
    jwk: JWK? = nil)
  {
    self.algorithm = algorithm
    self.type = type
    self.keyIdentifier = keyIdentifier
    self.jwk = jwk
  }

  // MARK: Public

  /// Header algorithm value aka `alg` in a JWSHeader
  public let algorithm: JWTAlgorithm

  /// Header type value aka `typ` in a JWSHeader
  public let type: String?

  /// The key ID is a hint indicating which key was used to secure the JWS
  public let keyIdentifier: String?

  /// The key info
  public let jwk: JWK?

  // MARK: Equatable

  public static func == (lhs: JWSHeader, rhs: JWSHeader) -> Bool {
    lhs.algorithm == rhs.algorithm &&
      lhs.type == rhs.type &&
      lhs.keyIdentifier == rhs.keyIdentifier &&
      lhs.jwk == rhs.jwk
  }
}
