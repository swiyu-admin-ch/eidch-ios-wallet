import AnyCodable
import BITJWT
import BITSdJWT
import Foundation

// MARK: - ProtectedVerificationAuthorizationTrustStatementJWTError

enum ProtectedVerificationAuthorizationTrustStatementJWTError: Error {
  case missingAuthorizedFields
}

public typealias ProtectedVerificationAuthorizationTrustStatement = JWS<ProtectedVerificationAuthorizationTrustStatementJWT>

// MARK: - ProtectedVerificationAuthorizationTrustStatementJWT

public struct ProtectedVerificationAuthorizationTrustStatementJWT: TrustStatementJWT, Equatable {

  public var type: String? = "swiyu-protected-verification-authorization-trust-statement+jwt"

  public let subject: String?
  public let jwtId: UUID
  public let authorizedFields: [String]
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let status: VcSdJwtTokenStatus?
}

// MARK: Codable

extension ProtectedVerificationAuthorizationTrustStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    jwtId = try container.decode(UUID.self, forKey: .jwtId)
    authorizedFields = try container.decode([String].self, forKey: .authorizedFields)
    guard !authorizedFields.isEmpty else { throw ProtectedVerificationAuthorizationTrustStatementJWTError.missingAuthorizedFields }
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    status = try container.decode(VcSdJwtTokenStatus.self, forKey: .status)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case jwtId = "jti"
    case authorizedFields = "authorized_fields"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case status
  }
}

extension ProtectedVerificationAuthorizationTrustStatementJWT {
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
