import Foundation
import RealmSwift

public class CredentialActivityEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var createdAt = Date()

  @Persisted public var type: String
  @Persisted public var actorTrust: String
  @Persisted public var vcSchemaTrust: String
  @Persisted public var nonComplianceData: String?

  @Persisted public var claims = List<ActivityClaimEntity>()
  @Persisted public var actorDisplays = List<ActivityActorDisplayEntity>()
}
