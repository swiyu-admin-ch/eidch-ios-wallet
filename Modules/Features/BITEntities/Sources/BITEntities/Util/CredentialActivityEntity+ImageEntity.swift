import BITDataStore
import RealmSwift

extension CredentialActivityEntity {
  public var actorImages: Set<String> {
    Set(actorDisplays.compactMap(\.imageHash))
  }
}

extension Sequence<CredentialActivityEntity> {
  public func actorImages() -> Set<String> {
    reduce(into: Set<String>()) { result, activity in
      result.formUnion(activity.actorImages)
    }
  }
}

extension RealmDataStoreProtocol {
  public func removeUnreferencedImages(_ hashes: Set<String>) throws {
    guard !hashes.isEmpty else { return }
    let activities = try get(CredentialActivityEntity.self)
    for hash in hashes {
      let isNotReferenced = activities
        .filter { activity in
          activity.actorDisplays.contains(where: { $0.imageHash == hash })
        }
        .isEmpty

      if
        isNotReferenced,
        let image = try get(ImageEntity.self, forPrimaryKey: hash)
      {
        try delete(image)
      }
    }
  }
}
