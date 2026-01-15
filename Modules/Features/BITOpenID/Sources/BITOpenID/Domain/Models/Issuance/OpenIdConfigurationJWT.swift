import BITJWT
import Foundation

// MARK: - OpenIdConfigurationJWT

struct OpenIdConfigurationJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    issuer: String,
    subject: String,
    issuedAt: Date,
    expiredAt: Date?,
    openIdConfiguration: OpenIdConfiguration)
  {
    self.issuer = issuer
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.openIdConfiguration = openIdConfiguration
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decodeIfPresent(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    openIdConfiguration = try OpenIdConfiguration(from: decoder)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
  }

  let issuer: String?
  let subject: String?
  let issuedAt: Date?
  let expiredAt: Date?
  let openIdConfiguration: OpenIdConfiguration
}

extension OpenIdConfigurationJWT {
  var type: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
