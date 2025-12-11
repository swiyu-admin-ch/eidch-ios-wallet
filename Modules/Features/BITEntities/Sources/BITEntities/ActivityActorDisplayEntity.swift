import Foundation
import RealmSwift

public class ActivityActorDisplayEntity: EmbeddedObject {

  @Persisted public var name: String?
  @Persisted public var locale: String?
  @Persisted public var imageHash: String?

  public var image: Data? {
    guard let imageHash, let realm else { return nil }
    return realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHash)?.data
  }
}
