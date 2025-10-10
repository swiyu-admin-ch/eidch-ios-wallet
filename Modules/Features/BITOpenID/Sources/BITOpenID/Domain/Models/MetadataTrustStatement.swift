import BITCrypto
import BITJWT
import BITSdJWT
import Foundation

public typealias MetadataTrustStatement = SdJWS<MetadataTrustStatementPayload>

// MARK: - MetadataTrustStatementPayload

public struct MetadataTrustStatementPayload: LocalizedTrustStatement, Codable, Equatable {

  // MARK: Public

  public let type: String? = "vc+sd-jwt"

  public let vct: String
  public let issuer: String
  public let subject: String?
  public let issuedAt: Date
  public let statusList: VcSdJwtTokenStatusList

  public let activatedAt: Date?
  public let expiredAt: Date?

  public let orgNames: [String: String]?
  public let preferredLanguage: String?

  public var entityNames: [String: String] {
    orgNames ?? [:]
  }

  /// Gets the localized entity name considering the order of the given language codes
  public func getLocalizedEntityName(considering languageCodes: [String]) -> String {
    var name = languageCodes
      .flatMap { code in
        entityNames.filter { locale, _ in
          locale.hasPrefix("\(code)")
        }.values
      }.first
    if name == nil, let preferredLanguage {
      name = entityNames[preferredLanguage]
    }
    return name ?? CodingKeys.orgNames.rawValue
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
    case orgNames = "orgName"
    case preferredLanguage = "prefLang"
  }
}
