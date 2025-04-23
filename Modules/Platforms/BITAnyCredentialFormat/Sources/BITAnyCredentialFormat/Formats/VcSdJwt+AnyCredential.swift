import BITSdJWT
import Foundation

// MARK: - VcSdJwt + AnyCredential

extension VcSdJwt: AnyCredential {

  public var format: String {
    CredentialFormat.vcSdJwt.rawValue
  }

  public var issuer: String {
    payload.issuer
  }

  public var claims: [any AnyClaim] {
    disclosableClaims
  }

  public var status: (any AnyStatus)? {
    payload.statusList
  }

  public var validFrom: Date? {
    payload.activatedAt
  }

  public var validUntil: Date? {
    payload.expiredAt
  }
}

// MARK: - SdJWTClaim + AnyClaim

extension SdJWTClaim: AnyClaim {}
