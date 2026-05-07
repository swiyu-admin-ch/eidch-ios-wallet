import BITCrypto
import BITJWT
import Foundation

public typealias VcSdJWS = SdJWS<VcSdJwt>

// MARK: - VcSdJwt

// https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-04.html

public struct VcSdJwt: JWT, Codable, Equatable {

  // MARK: Public

  #warning("legacyType to be deleted when contraction on dc+sd-jwt happens. Also delete the multi acceptedTypes in JWSDecoder.swift:39")
  public static let legacyType = "vc+sd-jwt"
  public static let currentType = "dc+sd-jwt"

  public static let vctPath = "$.vct"

  public let type: String? = Self.legacyType

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

  public var acceptedTypes: [String]? {
    [Self.legacyType, Self.currentType]
  }

  // registered claims can be found [here](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-05.html#name-registered-jwt-claims)

  public var issuer: String? {
    requiredIssuer
  }

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
    public let jwk: JWK
  }
}

extension VcSdJwt {
  public var audience: String? {
    nil
  }
}
