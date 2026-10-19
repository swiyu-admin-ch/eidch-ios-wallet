import BITDataStore
import Factory
import RealmSwift

// MARK: - ContentHashedEntity

/// A row keyed by the hash of the content it holds, so that two entities holding the same content
/// are stored once and every owner of that content ends up on the same row.
public protocol ContentHashedEntity: Object {
  var contentHash: String { get set }
}

extension ContentHashedEntity {

  /// Keys the row by the content it now holds. To be called once the row is fully populated.
  public func updateContentHash() {
    contentHash = Container.shared.contentHasher().hash(self)
  }

  /// Returns the row the store already holds for this content, or this one if it holds none.
  ///
  /// - Parameter realm: the realm of the owner being built, which the row itself cannot offer yet.
  public func resolvedByContentHash(in realm: Realm?) -> Self {
    resolvedByContentHash(in: realm)
  }
}
