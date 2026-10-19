import Foundation
import RealmSwift

public class VerifiableCredentialEntity: Object {

  public enum ProgressionState: String, PersistableEnum, Sendable {
    case accepted
    case unaccepted
  }

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var progressionState: ProgressionState
  @Persisted public var issuer: String

  @Persisted public var validFrom: Date?
  @Persisted public var validUntil: Date?

  @Persisted public var createdAt = Date()
  @Persisted public var refreshedAt: Date?
  @Persisted public var lastRefreshAttemptAt: Date?

  @Persisted public var bundleItems = List<BundleItemEntity>()
  @Persisted public var nextPresentableBundleItemId: UUID

  @Persisted public var batchData: BatchDataEntity?
}
