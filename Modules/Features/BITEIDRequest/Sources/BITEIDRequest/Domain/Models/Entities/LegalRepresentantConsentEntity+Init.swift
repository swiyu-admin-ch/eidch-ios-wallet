import BITEntities

extension LegalRepresentantConsentEntity {

  init(_ consent: LegalRepresentantConsent) {
    switch consent {
    case .verified: self = .verified
    case .notVerified: self = .notVerified
    case .notRequired: self = .notRequired
    }
  }
}
