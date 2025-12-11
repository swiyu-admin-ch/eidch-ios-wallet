import BITCrypto
import BITJWT
import Foundation

public typealias VcSdJwt = SdJWS<VcSdJwtPayload>

// MARK: - VcSdJwtPayload

/// https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-04.html

public struct VcSdJwtPayload: JWTPayload, Codable, Equatable {

  // MARK: Public

  public static let vctPath = "$.vct"

  public let type: String? = "vc+sd-jwt"

  /// registered claims can be found [here](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-05.html#name-registered-jwt-claims)

  public var issuer: String

  public var activatedAt: Date?

  public var expiredAt: Date?

  public var keyBinding: KeyBinding?

  public var vct: String

  public var vctIntegrity: String?

  public var statusList: VcSdJwtTokenStatusList?

  public var subject: String?

  public var issuedAt: Date?

  public var vctMetadataUri: String?

  public var vctMetadataUriIntegrity: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case keyBinding = "cnf"
    case vct
    case vctIntegrity = "vct#integrity"
    case statusList = "status"
    case subject = "sub"
    case issuedAt = "iat"
    case vctMetadataUri = "vct_metadata_uri"
    case vctMetadataUriIntegrity = "vct_metadata_uri#integrity"
  }

}

// MARK: VcSdJwtPayload.KeyBinding

extension VcSdJwtPayload {

  public struct KeyBinding: Codable, Equatable {
    let jwk: JWK
  }
}
