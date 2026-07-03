#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialClaimClusterDisplayEntity: Mockable {
  public struct Mock {
    public static func create(
      id: UUID = UUID(),
      locale: String = "locale",
      name: String = "name",
      createParent: Bool = true) throws
      -> CredentialClaimClusterDisplayEntity
    {
      let entity = CredentialClaimClusterDisplayEntity()
      entity.id = id
      entity.locale = locale
      entity.name = name

      try Realm.save(entity)
      if createParent {
        _ = try CredentialClaimClusterEntity.Mock.create(displays: [entity])
      }
      return entity
    }
  }
}
#endif
