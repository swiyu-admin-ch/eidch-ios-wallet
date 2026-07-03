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

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
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

    // MARK: Lifecycle

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      if let jwk = try container.decodeIfPresent(JWK.self, forKey: .jwk) {
        self.jwk = jwk
        return
      }

      jwk = try JWK(from: decoder)
    }

    // MARK: Public

    public let jwk: JWK

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case jwk
    }
  }
}

extension VcSdJwt {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }
}
