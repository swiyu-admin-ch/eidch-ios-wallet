#if DEBUG
// swiftlint:disable force_try
import Factory
import RealmSwift

extension Realm {
  public static func save(_ object: some Object) throws {
    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())
    try realm.write {
      realm.add(object, update: .modified)
    }
  }
}
#endif
