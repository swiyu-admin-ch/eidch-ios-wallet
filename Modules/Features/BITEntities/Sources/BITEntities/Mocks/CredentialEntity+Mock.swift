#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialEntity: Mockable {
  public struct Mock {
    public static func create(id: UUID = UUID(), verifiableCredential: VerifiableCredentialEntity? = nil, displays: [CredentialDisplayEntity] = [], activities: [CredentialActivityEntity] = []) throws -> CredentialEntity {
      let entity = CredentialEntity()
      entity.id = id
      entity.verifiableCredential = verifiableCredential

      let displayList = List<CredentialDisplayEntity>()
      displayList.append(objectsIn: displays)
      entity.displays = displayList

      let activityList = List<CredentialActivityEntity>()
      activityList.append(objectsIn: activities)
      entity.activities = activityList

      try Realm.save(entity)
      return entity
    }
  }
}
#endif
