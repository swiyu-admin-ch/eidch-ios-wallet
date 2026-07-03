import BITJWT
import Foundation

// MARK: - DPoPJWT

/// RFC 9449 Section 4.2 defines the DPoP proof claims (`jti`, `htm`, `htu`, `iat`, `nonce`, `ath`).
/// https://www.rfc-editor.org/rfc/rfc9449.html#section-4.2
struct DPoPJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    jwtIdentifier: String,
    httpMethod: String,
    httpTargetURI: String,
    nonce: String? = nil,
    accessTokenHash: String? = nil,
    issuedAt: Date = Date())
  {
    self.jwtIdentifier = jwtIdentifier
    self.httpMethod = httpMethod
    self.httpTargetURI = httpTargetURI
    self.nonce = nonce
    self.accessTokenHash = accessTokenHash
    self.issuedAt = issuedAt
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case jwtIdentifier = "jti"
    case httpMethod = "htm"
    case httpTargetURI = "htu"
    case nonce
    case accessTokenHash = "ath"
    case issuedAt = "iat"
  }

  let type: String? = "dpop+jwt"
  let issuer: String? = nil
  let audience: String? = nil
  let subject: String? = nil
  let expiredAt: Date? = nil
  let activatedAt: Date? = nil

  let issuedAt: Date?
  let jwtIdentifier: String
  let httpMethod: String
  let httpTargetURI: String
  let nonce: String?
  let accessTokenHash: String?
}
