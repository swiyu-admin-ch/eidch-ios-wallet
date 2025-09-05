import Foundation
import RealmSwift

public class DeferredCredentialEntity: Object {

  @Persisted(primaryKey: true) public var id: String
  @Persisted public var accessToken: String
  @Persisted public var endpoint: String
  @Persisted public var createdAt: Date
}
