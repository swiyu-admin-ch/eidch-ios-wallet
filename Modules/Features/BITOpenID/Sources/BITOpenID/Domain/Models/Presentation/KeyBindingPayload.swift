import BITJWT
import Foundation

/// https://www.ietf.org/archive/id/draft-ietf-oauth-selective-disclosure-jwt-10.html
struct KeyBindingPayload: JWTPayload, Codable, Equatable {

  // MARK: Lifecycle

  init(sdHash: String, audience: String = UUID().uuidString, nonce: String? = nil, issuedAt: Double = Date().timeIntervalSince1970) {
    self.sdHash = sdHash
    self.audience = audience
    self.nonce = nonce
    self.issuedAt = issuedAt
  }

  // MARK: Public

  public let type: String? = "kb+jwt"

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case audience = "aud"
    case nonce
    case issuedAt = "iat"
    case sdHash = "sd_hash"
  }

  // MARK: Private

  private let sdHash: String
  private let audience: String
  private let nonce: String?
  private let issuedAt: Double

}
