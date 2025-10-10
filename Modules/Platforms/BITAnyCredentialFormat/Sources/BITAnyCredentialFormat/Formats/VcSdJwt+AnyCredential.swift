import BITSdJWT
import Foundation

// MARK: - VcSdJwt + AnyCredential

extension VcSdJwt: AnyCredential {

  public var raw: String {
    rawSdJWS
  }

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

  public var vcSchemaId: String {
    payload.vct
  }

  public func getClaimsDictionary(_ claimSet: ClaimKind) -> [String: Any?] {
    switch claimSet {
    case .all:
      resolvedPayloadDictionary
    case .nonTechnical:
      resolvedPayloadDictionary.filter { !SdJWSDecoder.reservedClaimNames.contains($0.key) }
    }
  }
}

// MARK: - SdJWTClaim + AnyClaim

extension SdJWTClaim: AnyClaim {
  public var key: String {
    jsonPath
  }
}
