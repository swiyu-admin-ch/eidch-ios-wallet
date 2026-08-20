import BITJWT
import Foundation

// MARK: - DPoPJWT

/// RFC 9449 Section 4.2 defines the DPoP proof claims (`jti`, `htm`, `htu`, `iat`, `nonce`, `ath`).
/// https://www.rfc-editor.org/rfc/rfc9449.html#section-4.2
public typealias DPoP = JWS<DPoPJWT>

// MARK: - DPoPJWT

public struct DPoPJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    jwtId: String = UUID().uuidString,
    httpMethod: String,
    httpTargetURI: String,
    nonce: String? = nil,
    accessTokenHash: String? = nil,
    requestBody: String? = nil,
    issuedAt: Date = Date())
  {
    self.jwtId = jwtId
    self.httpMethod = httpMethod
    self.httpTargetURI = httpTargetURI
    self.nonce = nonce
    self.accessTokenHash = accessTokenHash
    self.requestBody = requestBody
    self.issuedAt = issuedAt
  }

  // MARK: Public

  public let type: String? = "dpop+jwt"
  public let issuer: String? = nil
  public let audience: String? = nil
  public let subject: String? = nil
  public let expiredAt: Date? = nil
  public let activatedAt: Date? = nil
  public let issuedAt: Date?

  // MARK: Internal

  let jwtId: String
  let httpMethod: String
  let httpTargetURI: String
  let nonce: String?
  let accessTokenHash: String?
  let requestBody: String? // Non-standard claim for AV backend

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case jwtId = "jti"
    case httpMethod = "htm"
    case httpTargetURI = "htu"
    case nonce
    case accessTokenHash = "ath"
    case issuedAt = "iat"
    case requestBody = "req"
  }

}
