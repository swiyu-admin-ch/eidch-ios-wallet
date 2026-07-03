import BITJWT
import Foundation

// MARK: - CredentialIssuerMetadataJWT

struct CredentialIssuerMetadataJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    subject: String,
    issuedAt: Date,
    expiredAt: Date?,
    credentialIssuerMetadata: CredentialIssuerMetadata)
  {
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.credentialIssuerMetadata = credentialIssuerMetadata
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    credentialIssuerMetadata = try CredentialIssuerMetadata(from: decoder)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
  }

  static let typeIdentifier = "openidvci-issuer-metadata+jwt"

  let subject: String?
  let issuedAt: Date?
  let expiredAt: Date?
  let credentialIssuerMetadata: CredentialIssuerMetadata

  var type: String? {
    Self.typeIdentifier
  }

}

extension CredentialIssuerMetadataJWT {
  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
