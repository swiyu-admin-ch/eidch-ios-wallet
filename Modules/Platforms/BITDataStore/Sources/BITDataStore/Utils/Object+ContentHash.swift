import Factory
import RealmSwift

extension Object {

  /// Content-hashed rows are immutable, so an equivalent row already in the store is reused
  /// instead of rewritten and every owner of the same content ends up on the same row.
  ///
  /// Owners under construction have no realm to offer, so the store is opened here rather than
  /// left to the caller: a caller that passes none would get no resolution, and the row it saves
  /// would land on an existing key, where `add(update: .all)` overwrites the row every other owner
  /// reads. The lookup belongs on the thread that saves the graph, which is the one that built it.
  public func resolvedByContentHash(in realm: Realm? = nil) -> Self {
    let contentHasher = Container.shared.contentHasher()

    guard
      contentHasher.isContentHashed(self),
      let key = self[ContentHasher.contentHashKey] as? String,
      let realm = realm ?? self.realm ?? (try? Realm(configuration: Container.shared.realmDataStoreConfiguration()))
    else {
      return self
    }

    if let existing = realm.object(ofType: Self.self, forPrimaryKey: key) {
      return existing
    }

    guard realm.isInWriteTransaction else { return self }

    return realm.create(Self.self, value: self, update: .modified)
  }
}
