import Foundation

// MARK: - ActorInformationBadgeType

public enum ActorInformationBadgeType: Hashable {
  case trusted
  case notTrusted
  case unknownTrust
  case legitimateIssuer
  case legitimateVerifier
  case notLegitimateIssuer
  case notLegitimateVerifier
  case notCompliant(reason: String)
}

#if DEBUG

// MARK: Equatable

extension ActorInformationBadgeType: Equatable {
  public static func == (_ lhs: ActorInformationBadgeType, _ rhs: ActorInformationBadgeType) -> Bool {
    switch (lhs, rhs) {
    case (.legitimateIssuer, .legitimateIssuer),
         (.legitimateVerifier, .legitimateVerifier),
         (.notLegitimateIssuer, .notLegitimateIssuer),
         (.notLegitimateVerifier, .notLegitimateVerifier),
         (.notTrusted, .notTrusted),
         (.trusted, .trusted),
         (.unknownTrust, .unknownTrust):
      true
    case (.notCompliant(let lhsReason), .notCompliant(let rhsReason)):
      lhsReason == rhsReason
    default:
      false
    }
  }
}
#endif
