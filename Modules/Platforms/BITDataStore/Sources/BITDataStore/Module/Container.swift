import Factory
import Foundation
import OSLog
import RealmSwift

extension Container {

  public var dataStore: Factory<RealmDataStoreProtocol> {
    self {
      RealmDataStore(configuration: self.realmDataStoreConfiguration())
    }
  }

  public var dataStoreConfigurationManager: Factory<DataStoreConfigurationManagerProtocol> {
    self { DataStoreConfiguration() }
  }

  public var realmDataStoreConfiguration: Factory<Realm.Configuration> {
    self {
      let config = Realm.Configuration(schemaVersion: 2)
      Realm.Configuration.defaultConfiguration = config
      return config
    }.singleton
  }

}
