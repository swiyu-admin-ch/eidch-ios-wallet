import BITJWT
import Foundation

// MARK: - CredentialMetadataJWT

struct CredentialMetadataJWT: JWT, Codable {

  // MARK: Lifecycle

  init(
    issuer: String? = nil,
    subject: String,
    issuedAt: Date,
    expiredAt: Date?,
    credentialMetadata: CredentialMetadata)
  {
    self.issuer = issuer
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.credentialMetadata = credentialMetadata
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    credentialMetadata = try CredentialMetadata(from: decoder)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
  }

  static let typeIdentifier = "openidvci-issuer-metadata+jwt"

  let issuer: String?
  let subject: String?
  let issuedAt: Date?
  let expiredAt: Date?
  let credentialMetadata: CredentialMetadata

  var type: String? { Self.typeIdentifier }

}

// MARK: Equatable

extension CredentialMetadataJWT: Equatable {
  static func == (lhs: CredentialMetadataJWT, rhs: CredentialMetadataJWT) -> Bool {
    lhs.issuer == rhs.issuer
      && lhs.subject == rhs.subject
      && lhs.issuedAt == rhs.issuedAt
      && lhs.expiredAt == rhs.expiredAt
      && lhs.credentialMetadata == rhs.credentialMetadata
  }
}

extension CredentialMetadataJWT {
  var audience: String? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
