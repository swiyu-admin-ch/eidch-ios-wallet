import Foundation
import RealmSwift

public class DeferredCredentialEntity: Object {

  @Persisted(primaryKey: true) public var id: String
  @Persisted public var progressState: String
  @Persisted public var endpoint: String
  @Persisted public var createdAt: Date
  @Persisted public var pollingInterval: Int
  @Persisted public var polledAt: Date?
  @Persisted public var keyBindings = List<CredentialKeyBindingEntity>()
}
