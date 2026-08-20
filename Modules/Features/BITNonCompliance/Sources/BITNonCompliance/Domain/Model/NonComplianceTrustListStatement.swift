import BITCore
import BITJWT
import BITOpenID
import BITSdJWT
import Foundation

public typealias NonComplianceTrustListStatement = JWS<NonComplianceTrustListStatementJWT>

// MARK: - NonComplianceTrustListStatementJWT

public struct NonComplianceTrustListStatementJWT: TrustStatementJWT, Equatable {

  public var type: String? = "swiyu-non-compliance-trust-list-statement+jwt"

  public let jwtId: String
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let status: VcSdJwtTokenStatus?
  public let nonCompliantActors: [NonCompliantActor]
}

// MARK: Codable

extension NonComplianceTrustListStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    jwtId = try container.decode(String.self, forKey: .jwtId)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    status = try container.decode(VcSdJwtTokenStatus.self, forKey: .status)
    nonCompliantActors = try container.decode([NonCompliantActor].self, forKey: .nonCompliantActors)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case status
    case jwtId = "jti"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case nonCompliantActors = "non_compliant_actors"
  }
}

// MARK: NonComplianceTrustListStatementJWT.NonCompliantActor

extension NonComplianceTrustListStatementJWT {
  public struct NonCompliantActor: Codable, Equatable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
      reason = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: CodingKeys.reason.rawValue)

      let staticContainer = try decoder.container(keyedBy: CodingKeys.self)
      actor = try staticContainer.decode(String.self, forKey: .actor)
    }

    // MARK: Public

    public let actor: String
    public let reason: LocalizedDisplay<String>?

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case actor, reason
    }
  }
}

extension NonComplianceTrustListStatementJWT {
  public var issuer: String? {
    nil
  }

  public var subject: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }
}
