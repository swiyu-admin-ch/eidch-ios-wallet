import Factory
import Foundation
import OSLog
import RealmSwift

extension Container {

  // MARK: Public

  public var dataStore: Factory<RealmDataStoreProtocol> {
    self { RealmDataStore() }
  }

  public var dataStoreConfigurationManager: Factory<DataStoreConfigurationManagerProtocol> {
    self { DataStoreConfiguration() }
  }

  public var realmDataStoreConfiguration: Factory<Realm.Configuration> {
    self {
      // Database schema v6.9
      let schemaVersion: UInt64 = 29

      let config = Realm.Configuration(
        schemaVersion: schemaVersion,
        migrationBlock: { migration, oldVersion in
          self.migrationService().migrate(from: oldVersion, to: schemaVersion, migration: migration)
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
