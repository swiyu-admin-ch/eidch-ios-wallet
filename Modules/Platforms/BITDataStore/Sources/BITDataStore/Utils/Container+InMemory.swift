#if DEBUG
import Factory
import Foundation
import RealmSwift

extension Container {
  /// Points the store at an in-memory realm of its own, so that suites holding their own container
  /// can run in parallel without seeing each other's rows.
  public func configureInMemoryDataStore() {
    let configuration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
    Self.shared.realmDataStoreConfiguration.register { configuration }
  }
}
#endif
