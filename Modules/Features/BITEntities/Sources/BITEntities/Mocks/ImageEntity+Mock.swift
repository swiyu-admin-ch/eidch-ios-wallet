#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension ImageEntity: Mockable {
  public struct Mock {
    public static func create(imageHash: String = "imageHash", data: Data = Data()) throws -> ImageEntity {
      let entity = ImageEntity()
      entity.imageHash = imageHash
      entity.data = data

      try Realm.save(entity)
      return entity
    }
  }
}
#endif
