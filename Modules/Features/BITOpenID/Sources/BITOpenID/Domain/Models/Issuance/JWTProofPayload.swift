import BITCore
import BITJWT
import Foundation

// MARK: - JWTProofPayload

struct JWTProofPayload: JWTPayload, Codable, Equatable {

  let type: String? = "openid4vci-proof+jwt"

  let audience: String
  let nonce: String?
  let issuedAt: UInt64?

  init(audience: String, nonce: String? = nil, issuedAt: UInt64? = nil) {
    self.audience = audience
    self.nonce = nonce
    self.issuedAt = issuedAt
  }

  enum CodingKeys: String, CodingKey {
    case audience = "aud"
    case nonce
    case issuedAt = "iat"
  }
}

// MARK: JWTProofPayload.AdditionalHeaderParameter

extension JWTProofPayload {
  enum AdditionalHeaderParameter: String {
    case keyAttestation = "key_attestation"
  }
}
