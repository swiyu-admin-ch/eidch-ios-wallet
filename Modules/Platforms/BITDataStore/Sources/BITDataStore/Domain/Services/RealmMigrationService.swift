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
      return migrateFromSchema14(migration)
    }

    if oldVersion < 19 && newVersion >= 19 {
      return migrateFromSchema18(migration)
    }

    if oldVersion < 20 && newVersion >= 20 {
      return migrateFromSchema19(migration)
    }

    if oldVersion < 22 && newVersion >= 22 {
      return migrateFromSchema21(migration)
    }

    if oldVersion < 24 && newVersion >= 24 {
      return migrateFromSchema23(migration)
    }

    if oldVersion < 25 && newVersion >= 25 {
      return migrateFromSchema24(migration)
    }

    if oldVersion < 29 && newVersion >= 29 {
      return migrateFromSchema28(migration)
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
      let cluster = migration.create("CredentialClaimClusterEntity", value: [
        "id": UUID(),
        "path": "[]",
        "order": Int16.max,
        "claims": [],
        "childClusters": [],
        "displays": [],
      ])
      let clusterClaims = cluster["claims"] as? List<MigrationObject> ?? List()

      migration.enumerateObjects(ofType: "CredentialClaimEntity") { oldClaim, newClaim in
        if let oldClaim, oldClaims.contains(oldClaim), let newClaim {
          clusterClaims.append(newClaim)
        }
      }

      let keyBinding = createKeyBindingFromCredentialFields(oldCredential, migration: migration)
      let verifiableCredential = createVerifiableCredential(from: oldCredential, keyBinding: keyBinding, in: migration)
      let clusters = verifiableCredential?["clusters"] as? List<MigrationObject>
      clusters?.append(cluster)

      newCredential?["verifiableCredential"] = verifiableCredential
    }
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
    deleteOrphanedObjects(migration)
  }

  /**
   * Version 3.8 (schema 6)
   * - Remove **KeyBindingIdentifier** and **KeyBindingAlgorithm** from **CredentialEntity**
   * - Add **CredentialKeyBindingEntity** table
   */
  private func migrateFromSchema5(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let keyBinding = createKeyBindingFromCredentialFields(oldCredential, migration: migration)
      let verifiableCredential = createVerifiableCredential(from: oldCredential, keyBinding: keyBinding, in: migration)
      copyClusters(from: oldCredential, to: verifiableCredential, in: migration)

      newCredential?["verifiableCredential"] = verifiableCredential
    }
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
    deleteOrphanedObjects(migration)
  }

  /**
   * Version 5.0 (schema 11)
   * - Add **VerifiableCredentialEntity** table
   */
  private func migrateFromSchema10(_ migration: Migration) {
    let keyBindingsById = getOldToNewObjectMap(ofType: "CredentialKeyBindingEntity", migration: migration)
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      let keyBinding = getLegacyKeyBindingId(oldCredential).flatMap { keyBindingsById[$0] }
      let verifiableCredential = createVerifiableCredential(from: oldCredential, keyBinding: keyBinding, in: migration)
      copyClusters(from: oldCredential, to: verifiableCredential, in: migration)

      newCredential?["verifiableCredential"] = verifiableCredential
    }
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
    deleteOrphanedObjects(migration)
  }

  /**
   * Version 6.1 (schema 15) (no schema change)
   * Fixes the progressionState = unaccepted for issued credentials created with MetadataCredentialGenerator
   */
  private func migrateFromSchema14(_ migration: Migration) {
    migration.enumerateObjects(ofType: "VerifiableCredentialEntity") { _, newCredential in
      newCredential?["progressionState"] = "accepted"
    }

    migrateSchema16To18CredentialStorage(migration)
    migrateBatchData(migration)
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)

    deleteOrphanedObjects(migration)
  }

  /**
   * Version 6.2+ (schema 17+)
   * - Removes orphaned objects
   * - Migrates legacy credential storage to bundle items / deferred key bindings
   */
  private func migrateFromSchema18(_ migration: Migration) {
    migrateSchema16To18CredentialStorage(migration)
    migrateBatchData(migration)
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)

    deleteOrphanedObjects(migration)

  }

  /**
   * Version 6.5 (schema 20)
   * - Add **nextPresentableBundleItemId** to **VerifiableCredentialEntity**
   */
  private func migrateFromSchema19(_ migration: Migration) {
    migrateBatchData(migration)
    setNextPresentableBundleItemId(in: migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
  }

  /**
   * Version 6.8 (schema 22)
   * - Add **CredentialAuthenticationEntity** table
   * - Add **DPoPBindingEntity** table
   * - Persist credential authentication at the root credential level
   */
  private func migrateFromSchema21(_ migration: Migration) {
    migrateBatchData(migration)
    migrateCredentialAuthentication(migration)
    replaceKeyWithClaimsPathPointer(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
  }

  /**
   * Version 6.6 (schema 23)
   * - Replace **CredentialClaimEntity.key** with **CredentialClaimEntity.path**
   */
  private func migrateFromSchema23(_ migration: Migration) {
    replaceKeyWithClaimsPathPointer(migration)
    migrateBatchData(migration)
    migrateCredentialAuthentication(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
  }

  private func replaceKeyWithClaimsPathPointer(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialClaimEntity") { oldClaim, newClaim in
      guard let newClaim else { return }
      if let key = oldClaim?["key"] as? String {
        newClaim["path"] = "[\"\(key)\"]"
      }
    }
  }

  /**
   * Version 6.8 (schema 25)
   * - adds CredentialAuthentication
   * - adds DPopBinding
   * - renames BatchRefreshData to BatchData
   * - moves access and refreshToken from DeferredCredential to CredentialAuthentication
   */
  private func migrateFromSchema24(_ migration: Migration) {
    migrateBatchData(migration)
    migrateCredentialAuthentication(migration)
    migrateCredentialDisplaySummaryTemplates(migration)
  }

  /**
   * Version 6.9 (schema 29) (no schema change)
   * - Replace JSON path templates in **CredentialDisplayEntity.summary** with claims path pointer templates
   */
  private func migrateFromSchema28(_ migration: Migration) {
    migrateCredentialDisplaySummaryTemplates(migration)
  }

  private func migrateCredentialDisplaySummaryTemplates(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialDisplayEntity") { oldDisplay, newDisplay in
      guard let summary: String = oldDisplay?.getValue(forProperty: "summary") else {
        return
      }

      newDisplay?["summary"] = summary.migrateJsonPathTemplatesToClaimsPathPointerTemplates()
    }
  }

  private func migrateCredentialAuthentication(_ migration: Migration) {
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      guard let newCredential else {
        return
      }

      newCredential["authentication"] = createCredentialAuthentication(from: oldCredential)
    }
  }

  private func deleteOrphanedObjects(_ migration: Migration) {
    let childrenMap = getCredentialChildrenIds(migration: migration)
    for (entityType, ids) in childrenMap {
      migration.deleteOrphanedObjects(ofType: entityType, ids: ids)
    }
    deleteOrphanedEIDRequestCaseStates(migration: migration)
  }

  private func getCredentialChildrenIds(migration: Migration) -> [String: [String]] {
    var childrenMap = [String: [String]]()
    migration.enumerateObjects(ofType: "CredentialEntity") { _, newCredential in
      if let newCredential {
        if let id = newCredential.getId(forChild: "rawCredentialData") {
          createOrAppend(&childrenMap, key: "RawCredentialDataEntity", value: id)
        }
        if
          let authentication = newCredential.getObject(forProperty: "authentication"),
          let dpopBindingId = authentication.getId(forChild: "dpopBinding")
        {
          createOrAppend(&childrenMap, key: "DPoPBindingEntity", value: dpopBindingId)
        }
        if let id = newCredential.getId(forChild: "deferredCredential") {
          createOrAppend(&childrenMap, key: "DeferredCredentialEntity", value: id)
          if let deferredCredential = newCredential["deferredCredential"] as? MigrationObject {
            createOrAppend(&childrenMap, key: "CredentialKeyBindingEntity", value: deferredCredential.getIds(forChildren: "keyBindings"))
          }
        }
        if let id = newCredential.getId(forChild: "verifiableCredential") {
          createOrAppend(&childrenMap, key: "VerifiableCredentialEntity", value: id)
        }
        createOrAppend(&childrenMap, key: "CredentialIssuerDisplayEntity", value: newCredential.getIds(forChildren: "issuerDisplays"))
        createOrAppend(&childrenMap, key: "CredentialDisplayEntity", value: newCredential.getIds(forChildren: "displays"))
        if let verifiableCredential = newCredential["verifiableCredential"] as? MigrationObject {
          createOrAppend(&childrenMap, key: "BundleItemEntity", value: verifiableCredential.getIds(forChildren: "bundleItems"))
          if let bundleItems = verifiableCredential["bundleItems"] as? List<MigrationObject> {
            for bundleItem in bundleItems {
              if let id = bundleItem.getId(forChild: "keyBinding") {
                createOrAppend(&childrenMap, key: "CredentialKeyBindingEntity", value: id)
              }
            }
          }
          if let id = verifiableCredential.getId(forChild: "batchData") {
            createOrAppend(&childrenMap, key: "BatchDataEntity", value: id)
          }
          createOrAppend(&childrenMap, key: "CredentialClaimClusterEntity", value: verifiableCredential.getIds(forChildren: "clusters"))
          if let clusters = verifiableCredential["clusters"] as? List<MigrationObject> {
            let clusterDisplayIds: [String] = clusters.flatMap { $0.getIds(forChildren: "displays") }
            createOrAppend(&childrenMap, key: "CredentialClaimClusterDisplayEntity", value: clusterDisplayIds)
            for cluster in clusters {
              createOrAppend(&childrenMap, key: "CredentialClaimEntity", value: cluster.getIds(forChildren: "claims"))
              if let claims = cluster["claims"] as? List<MigrationObject> {
                let claimDisplayIds: [String] = claims.flatMap { $0.getIds(forChildren: "displays") }
                createOrAppend(&childrenMap, key: "CredentialClaimDisplayEntity", value: claimDisplayIds)
              }
            }
          }
        }
      }
    }
    return childrenMap
  }

  private func createOrAppend(_ dictionary: inout [String: [String]], key: String, value: String) {
    if dictionary[key] == nil {
      dictionary[key] = [value]
    } else {
      dictionary[key]?.append(value)
    }
  }

  private func createOrAppend(_ dictionary: inout [String: [String]], key: String, value: [String]) {
    if dictionary[key] == nil {
      dictionary[key] = value
    } else {
      dictionary[key]?.append(contentsOf: value)
    }
  }

  private func deleteOrphanedEIDRequestCaseStates(migration: Migration) {
    var caseStateIds = [String]()
    migration.enumerateObjects(ofType: "EIDRequestCaseEntity") { oldCase, _ in
      if let ids = oldCase?.getId(forChild: "state") {
        caseStateIds.append(ids)
      }
    }
    migration.deleteOrphanedObjects(ofType: "EIDRequestStateEntity", ids: caseStateIds)
  }

  private func createVerifiableCredential(from oldCredential: MigrationObject?, keyBinding: MigrationObject?, in migration: Migration) -> MigrationObject? {
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
      "progressionState": "accepted",
      "issuer": issuer,
      "createdAt": createdAt,
      "validFrom": oldCredential?["validFrom"] as? Date,
      "nextPresentableBundleItemId": UUID(),
    ])

    // Check if validUntil exist before trying to set it. Version 3.2 users do not have that property
    if oldCredential?.objectSchema.properties.first(where: { $0.name == "validUntil" }) != nil {
      verifiableCredential["validUntil"] = oldCredential?["validUntil"] as? Date
    } else {
      verifiableCredential["validUntil"] = nil
    }

    appendBundleItem(to: verifiableCredential, payload: payload, status: status, keyBinding: keyBinding, in: migration)
    setNextPresentableBundleItemId(in: migration, for: verifiableCredential)

    return verifiableCredential
  }

  private func createKeyBindingFromCredentialFields(_ oldCredential: MigrationObject?, migration: Migration) -> MigrationObject? {
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

  private func migrateSchema16To18CredentialStorage(_ migration: Migration) {
    let keyBindingsById = getOldToNewObjectMap(ofType: "CredentialKeyBindingEntity", migration: migration)
    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      migrateLegacyDeferredCredentialKeyBinding(
        oldCredential: oldCredential,
        newCredential: newCredential,
        keyBindingsById: keyBindingsById)
      migrateLegacyVerifiableCredentialPayloadToBundleItem(
        oldCredential: oldCredential,
        newCredential: newCredential,
        keyBindingsById: keyBindingsById,
        migration: migration)
    }
  }

  private func getOldToNewObjectMap(ofType type: String, migration: Migration) -> [String: MigrationObject] {
    var mapping = [String: MigrationObject]()
    migration.enumerateObjects(ofType: type) { oldObject, newObject in
      guard let oldId = oldObject?.getId(), let newObject else {
        return
      }
      mapping[oldId] = newObject
    }
    return mapping
  }

  private func getLegacyKeyBindingId(_ oldCredential: MigrationObject?) -> String? {
    guard
      let oldKeyBinding = oldCredential?["keyBinding"] as? MigrationObject,
      let oldKeyBindingId = oldKeyBinding.getId()
    else {
      return nil
    }

    return oldKeyBindingId
  }

  private func migrateLegacyDeferredCredentialKeyBinding(oldCredential: MigrationObject?, newCredential: MigrationObject?, keyBindingsById: [String: MigrationObject]) {
    let keyBinding = getLegacyKeyBindingId(oldCredential).flatMap { keyBindingsById[$0] }
    appendKeyBindingToDeferredCredential(newCredential, keyBinding: keyBinding)
  }

  private func appendKeyBindingToDeferredCredential(_ newCredential: MigrationObject?, keyBinding: MigrationObject?) {
    guard
      let keyBinding,
      let deferredCredential = newCredential?["deferredCredential"] as? MigrationObject,
      let keyBindings = deferredCredential["keyBindings"] as? List<MigrationObject>
    else {
      return
    }

    keyBindings.append(keyBinding)
  }

  private func migrateLegacyVerifiableCredentialPayloadToBundleItem(
    oldCredential: MigrationObject?,
    newCredential: MigrationObject?,
    keyBindingsById: [String: MigrationObject],
    migration: Migration)
  {
    guard
      let oldVerifiableCredential = oldCredential?["verifiableCredential"] as? MigrationObject,
      let newVerifiableCredential = newCredential?["verifiableCredential"] as? MigrationObject,
      let status = oldVerifiableCredential["status"] as? String,
      let payload = oldVerifiableCredential["payload"] as? Data
    else {
      return
    }

    let keyBinding = getLegacyKeyBindingId(oldCredential).flatMap { keyBindingsById[$0] }
    appendBundleItem(to: newVerifiableCredential, payload: payload, status: status, keyBinding: keyBinding, in: migration)
  }

  private func appendBundleItem(to verifiableCredential: MigrationObject, payload: Data, status: String, keyBinding: MigrationObject?, in migration: Migration) {
    let bundleItem = migration.create("BundleItemEntity", value: [
      "id": UUID(),
      "payload": payload,
      "status": status,
      "presented": false,
    ])
    bundleItem["keyBinding"] = keyBinding

    let bundleItems = verifiableCredential["bundleItems"] as? List<MigrationObject>
    bundleItems?.append(bundleItem)
  }

  private func migrateBatchData(_ migration: Migration) {
    migration.enumerateObjects(ofType: "VerifiableCredentialEntity") { oldVerifiableCredential, newVerifiableCredential in
      guard
        let newVerifiableCredential,
        let batchRefreshData = oldVerifiableCredential?.getObject(forProperty: "batchRefreshData"),
        let batchSize: Int = batchRefreshData.getValue(forProperty: "batchSize")
      else {
        return
      }

      newVerifiableCredential["batchData"] = migration.create("BatchDataEntity", value: [batchSize])
    }
  }

  private func createCredentialAuthentication(from oldCredential: MigrationObject?) -> [String: Any] {
    let verifiableCredential = oldCredential?.getObject(forProperty: "verifiableCredential")
    let batchRefreshData = verifiableCredential?.getObject(forProperty: "batchRefreshData")
    let deferredCredential = oldCredential?.getObject(forProperty: "deferredCredential")

    let accessToken: String = deferredCredential?.getValue(forProperty: "accessToken") ?? ""
    let refreshToken: String? = deferredCredential?.getValue(forProperty: "refreshToken")
      ?? batchRefreshData?.getValue(forProperty: "refreshToken")

    var authentication: [String: Any] = [
      "tokenType": "bearer",
      "accessToken": accessToken,
    ]
    if let refreshToken {
      authentication["refreshToken"] = refreshToken
    }
    return authentication
  }

  private func setNextPresentableBundleItemId(in migration: Migration, for verifiableCredential: MigrationObject? = nil) {
    if let verifiableCredential {
      setNextPresentableBundleItemId(for: verifiableCredential)
      return
    }

    migration.enumerateObjects(ofType: "VerifiableCredentialEntity") { _, newCredential in
      guard let newCredential else {
        return
      }
      setNextPresentableBundleItemId(for: newCredential)
    }
  }

  private func setNextPresentableBundleItemId(for verifiableCredential: MigrationObject) {
    guard
      let bundleItems = verifiableCredential["bundleItems"] as? List<MigrationObject>
    else {
      return
    }

    let nextBundleItem = bundleItems.first(where: { ($0["presented"] as? Bool) == false }) ?? bundleItems.first
    if
      let nextBundleItemId = nextBundleItem?.getId(),
      let nextBundleItemIdUuid = UUID(uuidString: nextBundleItemId)
    {
      verifiableCredential["nextPresentableBundleItemId"] = nextBundleItemIdUuid
    }
  }
}

extension Migration {
  fileprivate func deleteOrphanedObjects(ofType type: String, ids: [String]) {
    enumerateObjects(ofType: type) { _, newObject in
      let childId = (newObject?["id"] as? UUID)?.uuidString ?? newObject?["id"] as? String
      if let childId, let newObject {
        if !ids.contains(childId) {
          delete(newObject)
        }
      }
    }
  }
}

extension MigrationObject {
  fileprivate func hasProperty(_ property: String) -> Bool {
    objectSchema.properties.contains(where: { $0.name == property })
  }

  fileprivate func getObject(forProperty property: String) -> MigrationObject? {
    guard hasProperty(property) else {
      return nil
    }

    return self[property] as? MigrationObject
  }

  fileprivate func getValue<T>(forProperty property: String) -> T? {
    guard hasProperty(property) else {
      return nil
    }

    return self[property] as? T
  }

  fileprivate func getId() -> String? {
    if let uuid = self["id"] as? UUID {
      return uuid.uuidString
    }
    return self["id"] as? String
  }

  fileprivate func getId(forChild child: String) -> String? {
    let childObject = self[child] as? MigrationObject
    return childObject?.getId()
  }

  fileprivate func getIds(forChildren children: String) -> [String] {
    let childrenObject = self[children] as? List<MigrationObject>
    return childrenObject?.compactMap {
      if let uuid = $0["id"] as? UUID {
        return uuid.uuidString
      }
      return $0["id"] as? String
    } ?? []
  }
}
