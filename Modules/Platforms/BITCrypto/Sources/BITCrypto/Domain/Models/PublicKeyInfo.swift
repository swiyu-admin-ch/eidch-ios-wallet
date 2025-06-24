import Foundation

///  Defines the structure for public key information utilizing JSON Web Key Sets (JWKS)
///  as specified in RFC 7517 and RFC 8037. This struct provides a method to decode and
///  equate JWKS, facilitating cryptographic operations like signature validation.
///
/// - RFC 7517: https://www.rfc-editor.org/rfc/rfc7517.html
/// - RFC 8037: https://www.rfc-editor.org/rfc/rfc8037.html
public struct PublicKeyInfo: Codable, Equatable {

  // MARK: Public

  public let jwks: [JWK]

  // MARK: Fileprivate

  fileprivate enum CodingKeys: String, CodingKey {
    case jwks = "keys"
  }
}
