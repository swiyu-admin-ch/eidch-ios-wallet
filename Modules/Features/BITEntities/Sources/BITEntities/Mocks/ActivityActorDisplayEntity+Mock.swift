#if DEBUG
import Foundation
@testable import BITCore

extension ActivityActorDisplayEntity: Mockable {
  public struct Mock {
    public static func create(name: String? = nil, locale: UserLocale? = nil, imageHash: String? = nil, createParent: Bool = true) throws -> ActivityActorDisplayEntity {
      let entity = ActivityActorDisplayEntity()
      entity.name = name
      entity.locale = locale
      entity.imageHash = imageHash

      if createParent {
        _ = try CredentialActivityEntity.Mock.create(actorDisplays: [entity])
      }
      return entity
    }
  }
}
#endif
