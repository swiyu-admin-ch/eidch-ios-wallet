import BITEntities
import Foundation

extension CredentialActivityEntity {

  // MARK: Lifecycle

  public convenience init(_ activity: Activity) {
    self.init()
    id = activity.id
    setValues(from: activity)
    claims.append(objectsIn: activity.claims.map(ActivityClaimEntity.init))
    actorDisplays.append(objectsIn: activity.actorDisplays.map(ActivityActorDisplayEntity.init))
  }

  // MARK: Public

  public func setValues(from activity: Activity) {
    type = activity.type.rawValue
    createdAt = activity.createdAt
    actorTrust = activity.actorTrust.rawValue
    vcSchemaTrust = activity.vcSchemaTrust.rawValue
    nonComplianceData = activity.nonComplianceData
  }
}
