import BITCrypto
import BITJWT
import Foundation

public typealias VcSdJWS = SdJWS<VcSdJwt>

// MARK: - VcSdJwt

/// https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-04.html

public struct VcSdJwt: JWT, Codable, Equatable {

  // MARK: Public

  public static let vctPath = "$.vct"

  public let type: String? = "vc+sd-jwt"

  public var requiredIssuer: String

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

  /// registered claims can be found [here](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-05.html#name-registered-jwt-claims)

  public var issuer: String? { requiredIssuer }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case requiredIssuer = "iss"
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

// MARK: VcSdJwt.KeyBinding

extension VcSdJwt {

  public struct KeyBinding: Codable, Equatable {
    let jwk: JWK
  }
}

extension VcSdJwt {
  public var audience: String? {
    nil
  }
}
