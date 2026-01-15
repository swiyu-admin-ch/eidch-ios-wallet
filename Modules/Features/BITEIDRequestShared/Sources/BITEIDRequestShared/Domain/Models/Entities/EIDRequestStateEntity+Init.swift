import BITEntities
import Foundation

extension EIDRequestStateEntity {

  convenience init(_ eIDRequestState: EIDRequestState) {
    self.init()
    id = eIDRequestState.id
    state = eIDRequestState.state.rawValue
    lastPolledAt = eIDRequestState.lastPolledAt
    onlineSessionStartOpenAt = eIDRequestState.onlineSessionStartOpenAt
    onlineSessionStartTimeoutAt = eIDRequestState.onlineSessionStartTimeoutAt
    legalRepresentantConsent = LegalRepresentantConsentEntity(eIDRequestState.legalRepresentantConsent)
  }

}
