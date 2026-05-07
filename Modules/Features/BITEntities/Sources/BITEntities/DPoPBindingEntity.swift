import Foundation
import RealmSwift

public class DPoPBindingEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var algorithm: String
  @Persisted public var bindingType: String
  @Persisted public var publicKey: Data?
  @Persisted public var privateKey: Data?
}
