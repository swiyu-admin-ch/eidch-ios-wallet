import Foundation
import RealmSwift

public class EIDRequestStateEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var state: EIDRequestStatusStateEntity
  @Persisted public var lastPolledAt: Date
  @Persisted public var onlineSessionStartOpenAt: Date?
  @Persisted public var onlineSessionStartTimeoutAt: Date?

  // Set default value to handle DB migration v2 to v3
  @Persisted public var legalRepresentantConsent = LegalRepresentantConsentEntity.notRequired
}
