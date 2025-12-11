import Foundation
import RealmSwift

public class ImageEntity: Object {

  @Persisted(primaryKey: true) public var imageHash: String
  @Persisted public var data: Data
}
