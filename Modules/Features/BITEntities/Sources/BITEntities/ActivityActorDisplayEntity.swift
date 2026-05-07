import BITCore
import Foundation
import RealmSwift

public class ActivityActorDisplayEntity: EmbeddedObject, DisplayLocalizable {

  @Persisted public var name: String?
  @Persisted public var locale: UserLocale?
  @Persisted public var imageHash: String?

  public var image: Data? {
    guard let imageHash, let realm else { return nil }
    return realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHash)?.data
  }
}
