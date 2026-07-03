#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialClaimDisplayEntity: Mockable {
  public struct Mock {
    public static func create(name: String? = nil, locale: UserLocale, value: String? = nil, createParent: Bool = true) throws -> CredentialClaimDisplayEntity {
      let entity = CredentialClaimDisplayEntity()
      entity.name = name
      entity.locale = locale
      entity.value = value

      try Realm.save(entity)
      if createParent {
        _ = try CredentialClaimEntity.Mock.create(displays: [entity])
      }
      return entity
    }
  }
}
#endif
