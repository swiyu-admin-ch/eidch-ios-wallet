import BITJWT
import Foundation

// MARK: - OpenIdConfigurationJWT

struct OpenIdConfigurationJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    subject: String,
    issuedAt: Date,
    expiredAt: Date?,
    openIdConfiguration: OpenIdConfiguration)
  {
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.openIdConfiguration = openIdConfiguration
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decodeIfPresent(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    openIdConfiguration = try OpenIdConfiguration(from: decoder)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
  }

  let subject: String?
  let issuedAt: Date?
  let expiredAt: Date?
  let openIdConfiguration: OpenIdConfiguration
}

extension OpenIdConfigurationJWT {
  var issuer: String? {
    nil
  }

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
