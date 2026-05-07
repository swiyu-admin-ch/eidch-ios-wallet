import BITCrypto
import BITJWT
import BITSdJWT
import Foundation

public typealias VcSchemaTrustStatement = SdJWS<VcSchemaTrustStatementJWT>

// MARK: - VcSchemaTrustStatementJWT

public struct VcSchemaTrustStatementJWT: TrustStatement, Codable, Equatable {

  // MARK: Lifecycle

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    vct = try container.decode(String.self, forKey: .vct)
    issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
    subject = try container.decodeIfPresent(String.self, forKey: .subject)
    issuedAt = try container.decodeIfPresent(Date.self, forKey: .issuedAt)
    statusList = try container.decode(VcSdJwtTokenStatusList.self, forKey: .statusList)
    activatedAt = try container.decodeIfPresent(Date.self, forKey: .activatedAt)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    vcSchemaId = try Self.decodeVcSchemaId(container: container)
  }

  // MARK: Public

  public let type: String? = VcSdJwt.legacyType

  public let vct: String
  public let issuer: String?
  public let subject: String?
  public let issuedAt: Date?
  public let statusList: VcSdJwtTokenStatusList

  public let activatedAt: Date?
  public let expiredAt: Date?

  public let vcSchemaId: URL?

  public var acceptedTypes: [String]? {
    [VcSdJwt.legacyType, VcSdJwt.currentType]
  }

  public func encode(to encoder: any Encoder) throws {
    abort() // will be implemented if we actually need it
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vct
    case issuer = "iss"
    case subject = "sub"
    case issuedAt = "iat"
    case statusList = "status"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case canIssue
    case canVerify
  }

  // MARK: Private

  private static func decodeVcSchemaId(container: KeyedDecodingContainer<CodingKeys>) throws -> URL? {
    if let canIssue = try? container.decode(URL.self, forKey: .canIssue) {
      return canIssue
    }
    return try container.decodeIfPresent(URL.self, forKey: .canVerify)
  }
}

extension VcSchemaTrustStatementJWT {
  public var audience: String? {
    nil
  }
}
