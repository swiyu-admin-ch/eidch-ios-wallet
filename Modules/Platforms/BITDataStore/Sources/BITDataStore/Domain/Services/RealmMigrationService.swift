import Foundation
import RealmSwift

// MARK: - MigrationServiceProtocol

protocol MigrationServiceProtocol {
  func migrate(from oldVersion: UInt64, to newVersion: UInt64, migration: Migration)
}

// MARK: - RealmMigrationService

struct RealmMigrationService: MigrationServiceProtocol {

  // MARK: Internal

  func migrate(from oldVersion: UInt64, to newVersion: UInt64, migration: Migration) {
    if oldVersion < 5 && newVersion >= 5 {
      migrateToSchema5(migration)
    }
    if oldVersion < 6 && newVersion >= 6 {
      migrateToSchema6(migration)
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

  private func migrateToSchema6(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      guard
        let id = oldCredential?["keyBindingIdentifier"] as? UUID,
        let algorithm = oldCredential?["keyBindingAlgorithm"] as? String
      else {
        return
      }

      let keyBinding = migration.create("CredentialKeyBindingEntity", value: [id, algorithm, "hardware", nil, nil])

      newCredential?["keyBinding"] = keyBinding
    }
  }
}
