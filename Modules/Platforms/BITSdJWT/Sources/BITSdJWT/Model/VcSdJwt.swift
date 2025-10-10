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

  public var keyBinding: ExpandedKeyBinding?

  public var vct: String

  public var vctIntegrity: String?

  public var statusList: VcSdJwtTokenStatusList?

  public var subject: String?

  public var issuedAt: Date?

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
  }

}

// MARK: VcSdJwtPayload.ExpandedKeyBinding

extension VcSdJwtPayload {

  /// Supporting temporarly both malformed and standard format of `cnf` claim.
  /// Example `cnf` content:
  /// {
  ///   "kty": "EC",
  ///   "crv": "P-256",
  ///   "x": "oXPOuWfF6dJWVhchYmalVp4kNgE1ShXN6wrtt4PQhY4",
  ///   "y": "LLSwewMUqxqX2eNLxx_BpTeC7dq1bxZQZv6lr6AsHQg",
  ///   "jwk": {
  ///     "kty": "EC",
  ///     "crv": "P-256",
  ///     "x": "oXPOuWfF6dJWVhchYmalVp4kNgE1ShXN6wrtt4PQhY4",
  ///     "y": "LLSwewMUqxqX2eNLxx_BpTeC7dq1bxZQZv6lr6AsHQg"
  ///   }
  /// }
  public struct ExpandedKeyBinding: Codable, Equatable {
    let jwk: JWK?

    let x: String?
    let y: String?
    let crv: String?
    let kty: String?
  }
}
