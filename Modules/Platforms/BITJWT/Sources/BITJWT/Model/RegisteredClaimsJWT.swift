import Foundation

// MARK: - RegisteredClaimsJWT

/// This class contains all registered claims which are specified by https://www.rfc-editor.org/rfc/rfc7519.html#section-4.1
public struct RegisteredClaimsJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  public init(
    issuer: String? = nil,
    subject: String? = nil,
    audience: String? = nil,
    expiredAt: Date? = nil,
    activatedAt: Date? = nil,
    issuedAt: Date? = nil)
  {
    self.issuer = issuer
    self.subject = subject
    self.audience = audience
    self.expiredAt = expiredAt
    self.activatedAt = activatedAt
    self.issuedAt = issuedAt
  }

  // MARK: Public

  public let type: String? = "jwt"

  public let issuer: String?
  public let subject: String?
  public let audience: String?
  public let expiredAt: Date?
  public let activatedAt: Date?
  public let issuedAt: Date?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case audience = "aud"
    case expiredAt = "exp"
    case activatedAt = "nbf"
    case issuedAt = "iat"
  }
}
