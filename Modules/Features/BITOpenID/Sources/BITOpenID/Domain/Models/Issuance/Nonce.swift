import Foundation

// MARK: - Nonce

/// Nonce response returned  as endpoint as defined in the OID4VCI specification.
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-nonce-endpoint
public struct Nonce: Codable, Equatable {

  public init(cNonce: String) {
    self.cNonce = cNonce
  }

  public let cNonce: String

  enum CodingKeys: String, CodingKey {
    case cNonce = "c_nonce"
  }
}
