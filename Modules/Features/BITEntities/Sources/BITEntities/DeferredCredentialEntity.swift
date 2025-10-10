import Foundation
import RealmSwift

public class DeferredCredentialEntity: Object {

  public enum ProgressionState: String, PersistableEnum {
    case inProgress
    case invalid
  }

  @Persisted(primaryKey: true) public var id: String
  @Persisted public var progressState: ProgressionState
  @Persisted public var accessToken: String
  @Persisted public var endpoint: String
  @Persisted public var createdAt: Date
  @Persisted public var pollingInterval: Int
  @Persisted public var polledAt: Date?
}
