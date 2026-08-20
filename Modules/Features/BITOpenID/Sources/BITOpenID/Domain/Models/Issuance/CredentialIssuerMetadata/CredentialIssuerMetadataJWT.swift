import BITJWT
import Foundation

// MARK: - CredentialIssuerMetadataJWT

public struct CredentialIssuerMetadataJWT: JWT, Codable, Equatable {

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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    credentialIssuerMetadata = try CredentialIssuerMetadata(from: decoder)
  }

  // MARK: Public

  public let subject: String?
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let credentialIssuerMetadata: CredentialIssuerMetadata

  public var type: String? {
    Self.typeIdentifier
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
  }

  static let typeIdentifier = "openidvci-issuer-metadata+jwt"
}

extension CredentialIssuerMetadataJWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }
}
