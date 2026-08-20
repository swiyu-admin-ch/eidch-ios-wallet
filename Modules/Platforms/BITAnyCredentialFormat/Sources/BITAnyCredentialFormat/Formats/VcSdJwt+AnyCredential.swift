import BITCore
import BITSdJWT
import Foundation

// MARK: - VcSdJWS + AnyCredential

extension VcSdJWS: AnyCredential {

  public var raw: String {
    rawSdJWS
  }

  public var format: CredentialFormat {
    CredentialFormat.vcSdJwt
  }

  public var issuer: String {
    keyIdentifierDid
  }

  public var status: (any AnyStatus)? {
    payload.status
  }

  public var validFrom: Date? {
    payload.activatedAt
  }

  public var validUntil: Date? {
    payload.expiredAt
  }

  public var businessExpiryDate: Date? {
    guard let dateString = resolvedJSON["expiry_date"] as? String else { return nil }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")

    guard let date = formatter.date(from: dateString) else { return nil }
    // set the expiry to the end of that day
    return Calendar.current.date(byAdding: .day, value: 1, to: date)
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
