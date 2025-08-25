import BITCrypto
import BITJWT
import BITSdJWT
import Foundation

public typealias TrustStatement = SdJWS<TrustStatementPayload>

// MARK: - TrustStatementPayload

public struct TrustStatementPayload: JWTPayload, Codable, Equatable {

  // MARK: Public

  public let type: String? = "vc+sd-jwt"

  public var issuer: String

  public var activatedAt: Date

  public var expiredAt: Date

  public var vct: String

  public var statusList: VcSdJwtTokenStatusList

  public var subject: String?

  public var issuedAt: Date

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case vct
    case statusList = "status"
    case subject = "sub"
    case issuedAt = "iat"
  }
}

extension TrustStatement {

  public var localizedIssuer: [String: Any] {
    let orgName = rawPayload["orgName"] as? [String: Any] ?? [:]
    let logoUri = rawPayload["logoUri"] as? [String: Any] ?? [:]

    let locales = Set(orgName.keys).union(logoUri.keys)

    return locales.reduce(into: [String: Any]()) { dict, locale in
      dict[locale] = [
        "name": orgName[locale] as? String as Any,
        "logo": logoUri[locale] as? URL as Any,
      ]
    }
  }
}
