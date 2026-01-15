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
      return migrateFromSchema4(migration)
    }

    if oldVersion < 6 && newVersion >= 6 {
      return migrateFromSchema5(migration)
    }

    if oldVersion < 11 && newVersion >= 11 {
      return migrateFromSchema10(migration)
    }

    if oldVersion < 15 && newVersion >= 15 {
      return migrateCredentialProgressionState(migration)
    }
  }

  // MARK: Private

  /**
   * Version 3.7 (schema 5)
   * - Add **CredentialClaimClusterEntity** table
   */
  private func migrateFromSchema4(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let oldClaims = oldCredential?["claims"] as? List<MigrationObject> ?? List()
      let cluster = migration.create("CredentialClaimClusterEntity", value: [UUID(), Int16.max, [], [], []])
      let clusterClaims = cluster["claims"] as? List<MigrationObject> ?? List()

      migration.enumerateObjects(ofType: "CredentialClaimEntity") { oldClaim, newClaim in
        if let oldClaim, oldClaims.contains(oldClaim), let newClaim {
          clusterClaims.append(newClaim)
        }
      }

      let verifiableCredential = createVerifiableCredential(from: oldCredential, in: migration)
      let clusters = verifiableCredential?["clusters"] as? List<MigrationObject>
      clusters?.append(cluster)

      newCredential?["verifiableCredential"] = verifiableCredential
      newCredential?["keyBinding"] = createKeyBinding(from: oldCredential, in: migration)
    }
  }

  /**
   * Version 3.8 (schema 6)
   * - Remove **KeyBindingIdentifier** and **KeyBindingAlgorithm** from **CredentialEntity**
   * - Add **CredentialKeyBindingEntity** table
   */
  private func migrateFromSchema5(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let verifiableCredential = createVerifiableCredential(from: oldCredential, in: migration)
      copyClusters(from: oldCredential, to: verifiableCredential, in: migration)

      newCredential?["verifiableCredential"] = verifiableCredential
      newCredential?["keyBinding"] = createKeyBinding(from: oldCredential, in: migration)
    }
  }

  /**
   * Version 5.0 (schema 11)
   * - Add **VerifiableCredentialEntity** table
   */
  private func migrateFromSchema10(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let verifiableCredential = createVerifiableCredential(from: oldCredential, in: migration)
      copyClusters(from: oldCredential, to: verifiableCredential, in: migration)

      newCredential?["verifiableCredential"] = verifiableCredential
    }
  }

  /**
   * Version 5.0 (schema 11) (no schema change)
   * Fixes the progressionState = unaccepted for issued credentials created with MetadataCredentialGenerator
   */
  private func migrateCredentialProgressionState(_ migration: Migration) {
    migration.enumerateObjects(ofType: "VerifiableCredentialEntity") { _, newCredential in
      newCredential?["progressionState"] = "accepted"
    }
  }

  private func createVerifiableCredential(from oldCredential: MigrationObject?, in migration: Migration) -> MigrationObject? {
    guard
      let status = oldCredential?["status"] as? String,
      let payload = oldCredential?["payload"] as? Data,
      let issuer = oldCredential?["issuer"] as? String,
      let createdAt = oldCredential?["createdAt"] as? Date
    else {
      return nil
    }

    let verifiableCredential = migration.create("VerifiableCredentialEntity", value: [
      "id": UUID(),
      "status": status,
      "progressionState": "accepted",
      "payload": payload,
      "issuer": issuer,
      "createdAt": createdAt,
      "validFrom": oldCredential?["validFrom"] as? Date,
    ])

    // Check if validUntil exist before trying to set it. Version 3.2 users do not have that property
    if oldCredential?.objectSchema.properties.first(where: { $0.name == "validUntil" }) != nil {
      verifiableCredential["validUntil"] = oldCredential?["validUntil"] as? Date
    } else {
      verifiableCredential["validUntil"] = nil
    }

    return verifiableCredential
  }

  private func createKeyBinding(from oldCredential: MigrationObject?, in migration: Migration) -> MigrationObject? {
    guard
      let id = oldCredential?["keyBindingIdentifier"] as? UUID,
      let algorithm = oldCredential?["keyBindingAlgorithm"] as? String
    else {
      return nil
    }

    return migration.create("CredentialKeyBindingEntity", value: [id, algorithm, "hardware", nil, nil])
  }

  private func copyClusters(from oldCredential: MigrationObject?, to verifiableCredential: MigrationObject?, in migration: Migration) {
    let oldClusters = oldCredential?["clusters"] as? List<MigrationObject> ?? List()
    let newClusters = verifiableCredential?["clusters"] as? List<MigrationObject> ?? List()

    migration.enumerateObjects(ofType: "CredentialClaimClusterEntity") { oldCluster, newCluster in
      if let oldCluster, oldClusters.contains(oldCluster), let newCluster {
        newClusters.append(newCluster)
      }
    }
  }
}
