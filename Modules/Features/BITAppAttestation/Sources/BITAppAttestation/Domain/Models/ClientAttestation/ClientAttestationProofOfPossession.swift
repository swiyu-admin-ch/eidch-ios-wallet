import BITJWT
import Foundation

// MARK: - ClientAttestationProofOfPossession

/// Client Attestation Proof of Possession (PoP) JWT
///
/// https://datatracker.ietf.org/doc/html/draft-ietf-oauth-attestation-based-client-auth-05
typealias ClientAttestationProofOfPossession = JWS<ClientAttestationProofOfPossessionPayload>

// MARK: - ClientAttestationProofOfPossessionPayload

struct ClientAttestationProofOfPossessionPayload: JWTPayload, Codable, Equatable {

  // MARK: Lifecycle

  init(expiredAt: Date, issuer: String, jwtIdentifier: String, audience: String, requestBody: String?, nonce: String? = nil, issuedAt: Date? = nil, activatedAt: Date? = nil) {
    self.expiredAt = expiredAt
    self.issuer = issuer
    self.jwtIdentifier = jwtIdentifier
    self.requestBody = requestBody
    self.nonce = nonce
    self.audience = audience
    self.issuedAt = issuedAt
    self.activatedAt = activatedAt
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case issuedAt = "iat"
    case jwtIdentifier = "jti"
    case nonce
    case requestBody = "req"
    case audience = "aud"
  }

  let type: String? = "oauth-client-attestation-pop+jwt"
  let expiredAt: Date
  let issuer: String
  let jwtIdentifier: String
  let issuedAt: Date?
  let activatedAt: Date?
  let nonce: String?
  let audience: String

  /// Hash of request body
  let requestBody: String?
}
