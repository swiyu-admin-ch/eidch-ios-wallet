import BITCore
import BITJWT
import Foundation

// MARK: - JWTProofPayload

public struct JWTProofPayload: JWTPayload, Codable, Equatable {

  public let type: String? = "openid4vci-proof+jwt"

  public let audience: String
  public let nonce: String?
  public let issuedAt: UInt64?

  public init(audience: String, nonce: String? = nil, issuedAt: UInt64? = nil) {
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
