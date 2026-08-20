import BITJWT
import BITSdJWT
import Foundation

public typealias ProtectedIssuanceTrustListStatement = JWS<ProtectedIssuanceTrustListStatementJWT>

// MARK: - ProtectedIssuanceTrustListStatementJWT

public struct ProtectedIssuanceTrustListStatementJWT: TrustStatementJWT, JWT, Equatable {

  public var type: String? = "swiyu-protected-issuance-trust-list-statement+jwt"

  public let jwtId: String
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let status: VcSdJwtTokenStatus?
  public let vctValues: [String]
}

// MARK: Codable

extension ProtectedIssuanceTrustListStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    jwtId = try container.decode(String.self, forKey: .jwtId)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    status = try container.decode(VcSdJwtTokenStatus.self, forKey: .status)
    vctValues = try container.decode([String].self, forKey: .vctValues)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case status
    case jwtId = "jti"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case vctValues = "vct_values"
  }
}

extension ProtectedIssuanceTrustListStatementJWT {
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
