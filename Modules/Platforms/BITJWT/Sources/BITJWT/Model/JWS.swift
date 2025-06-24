import BITCrypto
import Foundation

// MARK: - JWS

/// This class represents a signed JWT (JWS) which is specified by https://www.rfc-editor.org/rfc/rfc7515.html
/// The payload is generic and can consist of registered, public and private claims (see specifications for more details).

open class JWS<T: Codable & Equatable>: JWSValidatable, Equatable {

  // MARK: Lifecycle

  public init(
    payload: T,
    rawJWS: String,
    rawPayload: String,
    header: JWSHeader)
  {
    self.payload = payload
    self.rawJWS = rawJWS
    self.rawPayload = rawPayload
    self.header = header
  }

  // MARK: Public

  /// Payload that consists of registered, public and private claims that are known
  public let payload: T

  /// Raw JWS as it was before decoding
  public let rawJWS: String

  /// Raw payload json that consists of all registered, public and private claims
  public let rawPayload: String

  /// The header of the JWS
  public let header: JWSHeader

}

// MARK: Equatable

extension JWS {

  public static func == (lhs: JWS<T>, rhs: JWS<T>) -> Bool {
    lhs.payload == rhs.payload &&
      lhs.rawJWS == rhs.rawJWS &&
      lhs.rawPayload == rhs.rawPayload &&
      lhs.header == rhs.header
  }
}
