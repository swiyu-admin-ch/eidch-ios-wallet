import BITCrypto
import Foundation

// MARK: - JWS

/// This class represents a signed JWT (JWS) which is specified by https://www.rfc-editor.org/rfc/rfc7515.html
/// The payload is generic and can consist of registered, public and private claims (see specifications for more details).

open class JWS<T: JWT>: Equatable {

  // MARK: Lifecycle

  public init(
    payload: T,
    rawPayload: String,
    rawJWS: String,
    header: JWSHeader)
  {
    self.payload = payload
    self.rawPayload = rawPayload
    self.rawJWS = rawJWS
    self.header = header
  }

  // MARK: Public

  /// Payload that consists of registered, public and private claims that are known
  public let payload: T

  /// Raw payload json that consists of all registered, public and private claims
  public let rawPayload: String

  /// Raw JWS as it was before decoding
  public let rawJWS: String

  /// The header of the JWS
  public let header: JWSHeader

}

// MARK: Equatable

extension JWS {

  public static func == (lhs: JWS<T>, rhs: JWS<T>) -> Bool {
    lhs.payload == rhs.payload &&
      lhs.rawPayload == rhs.rawPayload &&
      lhs.rawJWS == rhs.rawJWS &&
      lhs.header == rhs.header
  }
}
