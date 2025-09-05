import BITEntities
import Foundation

extension EIDRequestStateEntity {

  convenience init(_ eIDRequestState: EIDRequestState) {
    self.init()
    id = eIDRequestState.id
    state = EIDRequestStatusStateEntity(eIDRequestState.state)
    lastPolledAt = eIDRequestState.lastPolledAt
    onlineSessionStartOpenAt = eIDRequestState.onlineSessionStartOpenAt
    onlineSessionStartTimeoutAt = eIDRequestState.onlineSessionStartTimeoutAt
    legalRepresentantConsent = LegalRepresentantConsentEntity(eIDRequestState.legalRepresentantConsent)
  }

}
