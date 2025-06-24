import Factory
import Foundation
import OSLog
import RealmSwift

extension Container {

  // MARK: Public

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
      let config = Realm.Configuration(
        schemaVersion: 5, // Database scheme v3.7
        migrationBlock: { migration, oldVersion in
          self.migrationService().migrate(from: oldVersion, migration: migration)
        })
      Realm.Configuration.defaultConfiguration = config
      return config
    }.singleton
  }

  // MARK: Internal

  var migrationService: Factory<MigrationServiceProtocol> {
    self { RealmMigrationService() }
  }

}
