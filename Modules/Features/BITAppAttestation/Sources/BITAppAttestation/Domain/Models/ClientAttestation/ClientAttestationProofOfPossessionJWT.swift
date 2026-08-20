import BITJWT
import Foundation

// MARK: - ClientAttestationProofOfPossession

/// Client Attestation Proof of Possession (PoP) JWT
///
/// https://datatracker.ietf.org/doc/html/draft-ietf-oauth-attestation-based-client-auth-05
public typealias ClientAttestationProofOfPossession = JWS<ClientAttestationProofOfPossessionJWT>

// MARK: - ClientAttestationProofOfPossessionJWT

public struct ClientAttestationProofOfPossessionJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    expiredAt: Date,
    issuer: String?,
    jwtId: String,
    audience: String?,
    requestBody: String?,
    nonce: String? = nil,
    issuedAt: Date? = nil,
    activatedAt: Date? = nil)
  {
    self.expiredAt = expiredAt
    self.issuer = issuer
    self.jwtId = jwtId
    self.requestBody = requestBody
    self.nonce = nonce
    self.audience = audience
    self.issuedAt = issuedAt
    self.activatedAt = activatedAt
  }

  // MARK: Public

  public let type: String? = "oauth-client-attestation-pop+jwt"

  public let issuedAt: Date?
  public let activatedAt: Date?
  public let expiredAt: Date?
  public let issuer: String?
  public let audience: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case issuedAt = "iat"
    case jwtId = "jti"
    case nonce
    case requestBody = "req"
    case audience = "aud"
  }

  let jwtId: String
  let nonce: String?

  /// Hash of request body
  let requestBody: String?
}

extension ClientAttestationProofOfPossessionJWT {
  public var subject: String? {
    nil
  }
}
