import AnyCodable
import BITJWT
import BITSdJWT
import BITSwiyuSharedKMP
import Foundation

public typealias VerificationQueryPublicStatement = JWS<VerificationQueryPublicStatementJWT>

// MARK: - VerificationQueryPublicStatementJWT

public struct VerificationQueryPublicStatementJWT: TrustStatementJWT, Equatable {

  public var type: String? = "swiyu-verification-query-public-statement+jwt"

  public let subject: String?
  public let jwtId: String
  public let purposeName: String?
  public let purposeDescription: String?
  public let request: VerificationRequestObject
  public let issuedAt: Date?
  public let expiredAt: Date?
}

// MARK: VerificationQueryPublicStatementJWT.VerificationRequestObject

extension VerificationQueryPublicStatementJWT {
  public struct VerificationRequestObject: Codable, Equatable {

    // MARK: Lifecycle

    public init(type: VerificationType, scope: String, dcqlQuery: DcqlQuery) {
      self.type = type
      self.scope = scope
      self.dcqlQuery = dcqlQuery
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey {
      case type
      case scope
      case dcqlQuery = "query"
    }

    public enum VerificationType: String, Codable, Equatable {
      case dcql = "DCQL"
    }

    public let type: VerificationType
    public let scope: String
    public let dcqlQuery: DcqlQuery
  }
}

// MARK: Codable

extension VerificationQueryPublicStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    jwtId = try container.decode(String.self, forKey: .jwtId)
    purposeName = try container.decode(String.self, forKey: .purposeName)
    purposeDescription = try container.decode(String.self, forKey: .purposeDescription)
    request = try container.decode(VerificationRequestObject.self, forKey: .request)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case jwtId = "jti"
    case purposeName = "purpose_name"
    case purposeDescription = "purpose_description"
    case request
    case issuedAt = "iat"
    case expiredAt = "exp"
  }
}

extension VerificationQueryPublicStatementJWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }

  public var status: VcSdJwtTokenStatus? {
    nil
  }
}
