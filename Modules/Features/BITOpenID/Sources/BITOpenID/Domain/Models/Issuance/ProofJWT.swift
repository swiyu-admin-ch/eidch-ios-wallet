import BITCore
import BITJWT
import Foundation

// MARK: - ProofJWT

struct ProofJWT: JWT, Codable, Equatable {

  let type: String? = "openid4vci-proof+jwt"

  let audience: String?
  let nonce: String?
  let issuedAt: Date?

  init(audience: String, nonce: String? = nil, issuedAt: Date? = nil) {
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

// MARK: ProofJWT.AdditionalHeaderParameter

extension ProofJWT {
  enum AdditionalHeaderParameter: String {
    case keyAttestation = "key_attestation"
  }
}

extension ProofJWT {
  var issuer: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
