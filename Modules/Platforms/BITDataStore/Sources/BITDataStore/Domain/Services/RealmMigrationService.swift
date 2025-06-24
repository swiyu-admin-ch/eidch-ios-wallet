import Foundation
import RealmSwift

// MARK: - MigrationServiceProtocol

protocol MigrationServiceProtocol {
  func migrate(from schemaVersion: UInt64, migration: Migration)
}

// MARK: - RealmMigrationService

struct RealmMigrationService: MigrationServiceProtocol {

  // MARK: Internal

  func migrate(from schemaVersion: UInt64, migration: Migration) {
    if schemaVersion < 5 {
      migrateToSchema5(migration)
    }
  }

  // MARK: Private

  private func migrateToSchema5(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let oldClaims = oldCredential?["claims"] as? List<MigrationObject> ?? List()

      let cluster = migration.create("CredentialClaimClusterEntity", value: [UUID(), Int16.max, [], [], []])
      let clusterClaims = cluster["claims"] as? List<MigrationObject> ?? List()

      migration.enumerateObjects(ofType: "CredentialClaimEntity") { oldClaim, newClaim in
        if let oldClaim, oldClaims.contains(oldClaim), let newClaim {
          clusterClaims.append(newClaim)
        }
      }

      let clusters = newCredential?["clusters"] as? List<MigrationObject>
      clusters?.append(cluster)
    }
  }
}
