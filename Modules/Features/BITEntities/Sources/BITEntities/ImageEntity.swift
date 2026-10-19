import Foundation
import RealmSwift

public class ImageEntity: Object, ContentHashedEntity {

  @Persisted(primaryKey: true) public var contentHash: String
  @Persisted public var image: Data
}
