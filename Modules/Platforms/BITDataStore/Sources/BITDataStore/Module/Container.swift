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
      // Database scheme v6.1
      let schemaVersion: UInt64 = 14

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
