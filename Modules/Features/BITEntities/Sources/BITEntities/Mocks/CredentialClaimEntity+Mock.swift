#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialClaimEntity: Mockable {
  public struct Mock {
    public static func create(id: UUID = UUID(), path: String = "[\"key\"]", value: String? = nil, displays: [CredentialClaimDisplayEntity] = [], createParent: Bool = true) throws -> CredentialClaimEntity {
      let entity = CredentialClaimEntity()
      entity.id = id
      entity.path = path
      entity.value = value

      let displayList = List<CredentialClaimDisplayEntity>()
      displayList.append(objectsIn: displays)
      entity.displays = displayList

      try Realm.save(entity)
      if createParent {
        _ = try CredentialClaimClusterEntity.Mock.create(claims: [entity])
      }
      return entity
    }
  }
}
#endif
