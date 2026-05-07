#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialActivityEntity: Mockable {
  public struct Mock {
    public static func create(
      id: UUID = UUID(),
      type: String = "issuance",
      nonComplianceData: String? = nil,
      createdAt: Date = Date(),
      actorTrust: String = "unknown",
      vcSchemaTrust: String = "notProtected",
      actorCompliance: String = "unknown",
      actorDisplays: [ActivityActorDisplayEntity] = [],
      nonComplianceReasonDisplays: [NonComplianceReasonDisplayEntity] = [],
      claims: [ActivityClaimEntity] = [],
      createParent: Bool = true) throws
      -> CredentialActivityEntity
    {
      let entity = CredentialActivityEntity()
      entity.id = id
      entity.type = type
      entity.nonComplianceData = nonComplianceData
      entity.createdAt = createdAt
      entity.actorTrust = actorTrust
      entity.vcSchemaTrust = vcSchemaTrust
      entity.actorCompliance = actorCompliance

      let actorList = List<ActivityActorDisplayEntity>()
      actorList.append(objectsIn: actorDisplays)
      entity.actorDisplays = actorList

      let reasonList = List<NonComplianceReasonDisplayEntity>()
      reasonList.append(objectsIn: nonComplianceReasonDisplays)
      entity.nonComplianceReasonDisplays = reasonList

      let claimList = List<ActivityClaimEntity>()
      claimList.append(objectsIn: claims)
      entity.claims = claimList

      try Realm.save(entity)
      if createParent {
        let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
        _ = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, activities: [entity])
      }
      return entity
    }
  }
}
#endif
