import BITEntities
import Foundation

public enum LegalRepresentantConsent: String, Equatable, Decodable {
  case verified = "VERIFIED"
  case notVerified = "NOT_VERIFIED"
  case notRequired = "NOT_REQUIRED"

  // MARK: Lifecycle

  init(_ consent: LegalRepresentantConsentEntity) {
    switch consent {
    case .verified: self = .verified
    case .notVerified: self = .notVerified
    case .notRequired: self = .notRequired
    }
  }

  init(_ legalRepresentant: EIDRequestStatus.LegalRepresentant?) {
    guard let legalRepresentant else {
      self = .notRequired
      return
    }

    self = legalRepresentant.isVerified ? .verified : .notVerified
  }
}
