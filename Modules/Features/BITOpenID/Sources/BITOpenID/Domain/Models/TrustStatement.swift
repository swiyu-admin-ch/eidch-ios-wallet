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

  public var issuedAt: Date?

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
