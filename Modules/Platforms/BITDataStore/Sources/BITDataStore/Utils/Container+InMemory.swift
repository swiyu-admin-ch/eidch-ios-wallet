#if DEBUG
// swiftlint:disable force_try
import Factory
import RealmSwift

extension Container {
  public func configureInMemoryDataStore() {
    let configuration = Realm.Configuration(inMemoryIdentifier: "inMemory")
    Self.shared.realmDataStoreConfiguration.register { configuration }
    let realm = try! Realm(configuration: configuration)
    try! realm.write {
      realm.deleteAll()
    }
  }
}
#endif
