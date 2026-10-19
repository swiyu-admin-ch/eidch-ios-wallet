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

  public var contentHasher: Factory<ContentHasherProtocol> {
    self { ContentHasher() }
  }

  public var realmDataStoreConfiguration: Factory<Realm.Configuration> {
    self {
      // Batch Activities + lastRefreshAttemptAt
      let schemaVersion: UInt64 = 33

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
