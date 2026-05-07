#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialDisplayEntity: Mockable {
  public struct Mock {
    public static func create(name: String? = nil, locale: UserLocale? = nil, summary: String? = nil, createParent: Bool = true) throws -> CredentialDisplayEntity {
      let entity = CredentialDisplayEntity()
      entity.name = name
      entity.locale = locale
      entity.summary = summary

      try Realm.save(entity)
      if createParent {
        _ = try CredentialEntity.Mock.create(displays: [entity])
      }
      return entity
    }
  }
}
#endif
