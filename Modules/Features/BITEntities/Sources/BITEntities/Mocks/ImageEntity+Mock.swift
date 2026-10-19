#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension ImageEntity: Mockable {
  public struct Mock {
    public static func create(contentHash: String = "imageHash", image: Data = Data()) throws -> ImageEntity {
      let entity = ImageEntity()
      entity.contentHash = contentHash
      entity.image = image

      try Realm.save(entity)
      return entity
    }
  }
}
#endif
