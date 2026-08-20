import BITCore
import BITJWT
import BITSdJWT
import Foundation

public typealias ProtectedIssuanceAuthorizationTrustStatement = JWS<ProtectedIssuanceAuthorizationTrustStatementJWT>

// MARK: - ProtectedIssuanceAuthorizationTrustStatementJWT

public struct ProtectedIssuanceAuthorizationTrustStatementJWT: TrustStatementJWT, JWT, Equatable {

  public var type: String? = "swiyu-protected-issuance-authorization-trust-statement+jwt"

  public let subject: String?
  public let jwtId: String
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let status: VcSdJwtTokenStatus?
  public let canIssue: CanIssue
}

// MARK: ProtectedIssuanceAuthorizationTrustStatementJWT.CanIssue

extension ProtectedIssuanceAuthorizationTrustStatementJWT {
  public struct CanIssue: Codable, Equatable {

    public init(from decoder: Decoder) throws {
      let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
      reason = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: CodingKeys.reason.rawValue)

      let staticContainer = try decoder.container(keyedBy: CodingKeys.self)
      vct = try staticContainer.decode(String.self, forKey: .vct)
      vctName = try staticContainer.decode(String.self, forKey: .vctName)
    }

    public let vct: String
    public let vctName: String
    public let reason: LocalizedDisplay<String>?

    private enum CodingKeys: String, CodingKey {
      case vct, reason
      case vctName = "vct_name"
    }
  }
}

// MARK: Codable

extension ProtectedIssuanceAuthorizationTrustStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    jwtId = try container.decode(String.self, forKey: .jwtId)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    status = try container.decode(VcSdJwtTokenStatus.self, forKey: .status)
    canIssue = try container.decode(CanIssue.self, forKey: .canIssue)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case status
    case jwtId = "jti"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case canIssue = "can_issue"
  }
}

extension ProtectedIssuanceAuthorizationTrustStatementJWT {
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
