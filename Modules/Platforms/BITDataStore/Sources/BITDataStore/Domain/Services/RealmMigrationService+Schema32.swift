import Foundation
import RealmSwift

/// The schema 32 step: the tables re-keyed onto a hash of their own content, the pointers that had
/// to follow them onto those keys, and the snapshots the activity history takes of both.
extension RealmMigrationService {

  // MARK: Internal

  func migrateToSchema32(_ migration: Migration) {
    renameProperty(in: migration, onType: "ImageEntity", from: "imageHash", to: "contentHash")
    renameProperty(in: migration, onType: "ImageEntity", from: "data", to: "image")
    migrateImageKeys(migration)
    migrateRawCredentialData(migration)
    dedupeRawCredentialData(migration)
    migrateCredentialRenderings(migration)
    migrateActivitySnapshots(migration)
  }

  /// The rendering is created with a placeholder key: its real key is the hash of the children that
  /// are attached to it afterwards.
  func rendering(for newCredential: MigrationObject, in migration: Migration) -> MigrationObject {
    if let existing = newCredential["credentialRendering"] as? MigrationObject {
      return existing
    }

    let rendering = migration.create("CredentialRenderingEntity", value: [
      "contentHash": UUID().uuidString,
      "createdAt": Date(),
    ])
    newCredential["credentialRendering"] = rendering
    return rendering
  }

  // MARK: Private

  /// Images were keyed by a digest of their bytes taken beside the row; they are now keyed like
  /// every other content-hashed table, by the hash of the row itself. Re-keying one means
  /// re-pointing everything that names it, and both have to happen before renderings are hashed:
  /// the pointer lives on a display, and a display is part of what a rendering hashes to.
  ///
  /// The bytes are read from the old row and written under the new names rather than being taken
  /// from the rename above, so this does not depend on when Realm applies that rename. Two images
  /// cannot collide on the new key without having collided on the old one.
  private func migrateImageKeys(_ migration: Migration) {
    var keysByOldKey = [String: String]()

    migration.enumerateObjects(ofType: "ImageEntity") { oldImage, newImage in
      guard let newImage else { return }

      if let image = (oldImage?["data"] as? Data) ?? (oldImage?["image"] as? Data) {
        newImage["image"] = image
      }

      let newKey = contentHasher.hash(newImage)
      if let oldKey = (oldImage?["imageHash"] as? String) ?? (oldImage?["contentHash"] as? String) {
        keysByOldKey[oldKey] = newKey
      }
      newImage["contentHash"] = newKey
    }

    guard !keysByOldKey.isEmpty else { return }

    repointImages(in: migration, onType: "CredentialDisplayEntity", property: "logoDataHash", using: keysByOldKey)
    repointImages(in: migration, onType: "CredentialIssuerDisplayEntity", property: "imageHash", using: keysByOldKey)

    migration.enumerateObjects(ofType: "CredentialActivityEntity") { _, newActivity in
      guard let displays = newActivity?["actorDisplays"] as? List<MigrationObject> else { return }

      for display in displays {
        repoint(display, property: "imageHash", using: keysByOldKey)
      }
    }
  }

  private func repointImages(in migration: Migration, onType type: String, property: String, using keysByOldKey: [String: String]) {
    migration.enumerateObjects(ofType: type) { _, newObject in
      guard let newObject else { return }

      repoint(newObject, property: property, using: keysByOldKey)
    }
  }

  private func repoint(_ object: MigrationObject, property: String, using keysByOldKey: [String: String]) {
    guard
      let oldKey = object[property] as? String,
      let newKey = keysByOldKey[oldKey]
    else {
      return
    }

    object[property] = newKey
  }

  private func migrateActivitySnapshots(_ migration: Migration) {
    renameProperty(in: migration, onType: "NonComplianceReasonDisplayEntity", from: "value", to: "reason")
    migrateActivityClaims(migration)

    migration.enumerateObjects(ofType: "CredentialEntity") { _, newCredential in
      guard
        let newCredential,
        let activities = newCredential["activities"] as? List<MigrationObject>
      else {
        return
      }

      let credentialRendering = newCredential["credentialRendering"] as? MigrationObject
      let rawCredentialData = newCredential["rawCredentialData"] as? MigrationObject
      let verifiableCredential = newCredential["verifiableCredential"] as? MigrationObject
      let issuer = verifiableCredential?["issuer"] as? String ?? ""
      let bundleItem = migratedBundleItem(of: verifiableCredential)

      for activity in activities {
        activity["credentialRendering"] = credentialRendering
        activity["rawCredentialData"] = rawCredentialData
        activity["issuer"] = issuer
        activity["bundleItem"] = bundleItem
      }
    }
  }

  private func migratedBundleItem(of verifiableCredential: MigrationObject?) -> [String: Any]? {
    guard
      let item = presentableBundleItem(of: verifiableCredential),
      let status = item["status"] as? String
    else {
      return nil
    }

    return ["statusListState": status]
  }

  private func presentableBundleItem(of verifiableCredential: MigrationObject?) -> MigrationObject? {
    guard
      let verifiableCredential,
      let bundleItems = verifiableCredential["bundleItems"] as? List<MigrationObject>,
      let nextPresentableBundleItemId = verifiableCredential["nextPresentableBundleItemId"] as? UUID
    else {
      return nil
    }

    return bundleItems.first { $0["id"] as? UUID == nextPresentableBundleItemId }
  }

  private func migrateActivityClaims(_ migration: Migration) {
    var pathsByClaimId = [String: String]()
    migration.enumerateObjects(ofType: "CredentialClaimEntity") { _, newClaim in
      guard
        let newClaim,
        let id = newClaim.getId(),
        let path = newClaim["path"] as? String
      else {
        return
      }
      pathsByClaimId[id] = path
    }

    migration.enumerateObjects(ofType: "CredentialActivityEntity") { oldActivity, newActivity in
      guard let oldClaims = oldActivity?.getChildren("claims"), let newActivity else { return }

      let paths = oldClaims.compactMap { oldClaim -> String? in
        guard let claimId = (oldClaim["credentialClaimId"] as? UUID)?.uuidString else { return nil }
        return pathsByClaimId[claimId]
      }

      newActivity["claims"] = paths.map { ["path": $0] }
    }
  }

  private func dedupeRawCredentialData(_ migration: Migration) {
    var survivorsByHash = [String: MigrationObject]()
    var duplicates = [MigrationObject]()

    migration.enumerateObjects(ofType: "RawCredentialDataEntity") { _, newRawCredentialData in
      guard
        let newRawCredentialData,
        let contentHash = newRawCredentialData["contentHash"] as? String
      else {
        return
      }

      if survivorsByHash[contentHash] == nil {
        survivorsByHash[contentHash] = newRawCredentialData
      } else {
        duplicates.append(newRawCredentialData)
      }
    }

    guard !duplicates.isEmpty else { return }

    migration.enumerateObjects(ofType: "CredentialEntity") { _, newCredential in
      guard
        let newCredential,
        let rawCredentialData = newCredential["rawCredentialData"] as? MigrationObject,
        let contentHash = rawCredentialData["contentHash"] as? String,
        let survivor = survivorsByHash[contentHash]
      else {
        return
      }

      newCredential["rawCredentialData"] = survivor
    }

    for duplicate in duplicates {
      migration.delete(duplicate)
    }
  }

  private func migrateCredentialRenderings(_ migration: Migration) {
    let displaysById = getOldToNewObjectMap(ofType: "CredentialDisplayEntity", migration: migration)
    let issuerDisplaysById = getOldToNewObjectMap(ofType: "CredentialIssuerDisplayEntity", migration: migration)
    let clustersById = getOldToNewObjectMap(ofType: "CredentialClaimClusterEntity", migration: migration)
    var renderingsByHash = [String: MigrationObject]()

    migration.enumerateObjects(ofType: "CredentialEntity") { oldCredential, newCredential in
      guard let newCredential else { return }

      let credentialRendering = rendering(for: newCredential, in: migration)
      attach(oldCredential?.getChildren("displays"), mappedBy: displaysById, to: credentialRendering, property: "displays")
      attach(oldCredential?.getChildren("issuerDisplays"), mappedBy: issuerDisplaysById, to: credentialRendering, property: "issuerDisplays")
      let oldVerifiableCredential = oldCredential?.getObject(forProperty: "verifiableCredential")
      attach(oldVerifiableCredential?.getChildren("clusters"), mappedBy: clustersById, to: credentialRendering, property: "clusters")

      let contentHash = contentHasher.hash(credentialRendering)
      if let survivor = renderingsByHash[contentHash] {
        newCredential["credentialRendering"] = survivor
        migration.delete(credentialRendering)
      } else {
        credentialRendering["contentHash"] = contentHash
        renderingsByHash[contentHash] = credentialRendering
      }
    }
  }

  private func attach(_ children: [MigrationObject]?, mappedBy map: [String: MigrationObject], to target: MigrationObject, property: String) {
    guard let children, let targetList = target[property] as? List<MigrationObject> else { return }

    for child in children {
      guard let id = child.getId(), let newChild = map[id] else { continue }
      targetList.append(newChild)
    }
  }

  private func migrateRawCredentialData(_ migration: Migration) {
    migration.enumerateObjects(ofType: "RawCredentialDataEntity") { _, newRawCredentialData in
      guard let newRawCredentialData else { return }

      newRawCredentialData["contentHash"] = contentHasher.hash(newRawCredentialData)
    }
  }

  private func renameProperty(in migration: Migration, onType type: String, from oldName: String, to newName: String) {
    guard migration.oldSchema[type]?.properties.contains(where: { $0.name == oldName }) == true else { return }
    migration.renameProperty(onType: type, from: oldName, to: newName)
  }
}
