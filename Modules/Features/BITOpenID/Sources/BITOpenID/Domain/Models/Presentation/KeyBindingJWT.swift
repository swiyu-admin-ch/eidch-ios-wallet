import BITJWT
import Foundation

// MARK: - KeyBindingJWT

/// https://www.ietf.org/archive/id/draft-ietf-oauth-selective-disclosure-jwt-10.html
struct KeyBindingJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(sdHash: String, audience: String, nonce: String? = nil, issuedAt: Date? = Date()) {
    self.sdHash = sdHash
    self.audience = audience
    self.nonce = nonce
    self.issuedAt = issuedAt
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case audience = "aud"
    case nonce
    case issuedAt = "iat"
    case sdHash = "sd_hash"
  }

  let type: String? = "kb+jwt"

  let issuedAt: Date?
  let audience: String?

  // MARK: Private

  private let sdHash: String

  private let nonce: String?

}

extension KeyBindingJWT {
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
