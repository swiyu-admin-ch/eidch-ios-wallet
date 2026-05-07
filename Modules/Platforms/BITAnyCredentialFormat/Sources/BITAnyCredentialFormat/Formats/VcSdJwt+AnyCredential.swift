import BITCore
import BITSdJWT
import Foundation

// MARK: - VcSdJWS + AnyCredential

extension VcSdJWS: AnyCredential {

  public var raw: String {
    rawSdJWS
  }

  public var format: String {
    CredentialFormat.vcSdJwt.rawValue
  }

  public var issuer: String {
    payload.requiredIssuer
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

  public var vcSchemaId: String {
    payload.vct
  }

  public func getClaimsJSON(_ claimSet: ClaimKind) -> JSON {
    switch claimSet {
    case .all:
      resolvedJSON
    case .nonTechnical:
      resolvedJSON.filter { !VcSdJWSDecoder.nonSelectivelyDisclosableClaims.contains($0.key) }
    }
  }
}

// MARK: - SdJWTClaim + AnyClaim

extension SdJWTClaim: AnyClaim {}
