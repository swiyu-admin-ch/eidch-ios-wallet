import BITJWT
import Foundation

// MARK: - CredentialIssuerMetadataJWT

struct CredentialIssuerMetadataJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(
    issuer: String? = nil,
    subject: String,
    issuedAt: Date,
    expiredAt: Date?,
    credentialIssuerMetadata: CredentialIssuerMetadata)
  {
    self.issuer = issuer
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.credentialIssuerMetadata = credentialIssuerMetadata
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    credentialIssuerMetadata = try CredentialIssuerMetadata(from: decoder)
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
  let credentialIssuerMetadata: CredentialIssuerMetadata

  var type: String? {
    Self.typeIdentifier
  }

}

extension CredentialIssuerMetadataJWT {
  var audience: String? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
