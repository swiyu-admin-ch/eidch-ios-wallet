import BITDataStore
import Factory
import RealmSwift

// MARK: - DatabaseCleanerProtocol

public protocol DatabaseCleanerProtocol: Sendable {

  /// Deletes the potential orphan candidates that a mutation just released, leaving every other row untouched.
  func deleteOrphans(among candidates: OrphanCandidates) throws

  /// Deletes every row no longer reachable from a credential or an activity.
  /// Repairs orphans left unchecked
  func deleteAllOrphans() throws
}

// MARK: - DatabaseCleaner

struct DatabaseCleaner: DatabaseCleanerProtocol {

  // MARK: Internal

  func deleteOrphans(among candidates: OrphanCandidates) throws {
    guard !candidates.isEmpty else { return }

    try remove(CredentialRenderingEntity.self, keys: candidates.renderingHashes.filter { try !isReferenced(rendering: $0) })
    try remove(RawCredentialDataEntity.self, keys: candidates.rawCredentialDataHashes.filter { try !isReferenced(rawCredentialData: $0) })
    try remove(ImageEntity.self, keys: candidates.imageHashes.filter { try !isReferenced(image: $0) })
  }

  func deleteAllOrphans() throws {
    try deleteAllOrphanedContentHashedRows()
    try deleteAllOrphanedImages()
  }

  // MARK: Private

  @Injected(\.dataStore) private var database

  private func deleteAllOrphanedContentHashedRows() throws {
    let credentials = try database.get(CredentialEntity.self)
    let activities = try database.get(CredentialActivityEntity.self)

    let renderings = Set(credentials.compactMap(\.credentialRendering?.contentHash))
      .union(activities.compactMap(\.credentialRendering?.contentHash))
    let rawCredentialData = Set(credentials.compactMap(\.rawCredentialData?.contentHash))
      .union(activities.compactMap(\.rawCredentialData?.contentHash))

    let orphanedRenderings = try Array(
      database.get(CredentialRenderingEntity.self)
        .filter { !renderings.contains($0.contentHash) })
    let orphanedRawCredentialData = try Array(
      database.get(RawCredentialDataEntity.self)
        .filter { !rawCredentialData.contains($0.contentHash) })

    try remove(orphanedRenderings)
    try remove(orphanedRawCredentialData)
  }

  private func deleteAllOrphanedImages() throws {
    let reachableImages = try getReachableImages()
    let orphanedImages = try Array(
      database.get(ImageEntity.self)
        .filter { !reachableImages.contains($0.contentHash) })

    try remove(orphanedImages)
  }

  private func getReachableImages() throws -> Set<String> {
    let activities = try database.get(CredentialActivityEntity.self)
    let credentialRenderings = try database.get(CredentialEntity.self).compactMap(\.credentialRendering)
    let snapshotRenderings = activities.compactMap(\.credentialRendering)

    return activities.actorImages()
      .union(credentialRenderings.displayImages())
      .union(snapshotRenderings.displayImages())
  }

  private func isReferenced(rendering contentHash: String) throws -> Bool {
    try isLinked(CredentialEntity.self, by: "credentialRendering.contentHash", to: contentHash)
      || isLinked(CredentialActivityEntity.self, by: "credentialRendering.contentHash", to: contentHash)
  }

  private func isReferenced(rawCredentialData contentHash: String) throws -> Bool {
    try isLinked(CredentialEntity.self, by: "rawCredentialData.contentHash", to: contentHash)
      || isLinked(CredentialActivityEntity.self, by: "rawCredentialData.contentHash", to: contentHash)
  }

  private func isReferenced(image contentHash: String) throws -> Bool {
    try isLinked(CredentialDisplayEntity.self, by: "logoDataHash", to: contentHash)
      || isLinked(CredentialIssuerDisplayEntity.self, by: "imageHash", to: contentHash)
      || isLinked(CredentialActivityEntity.self, by: "ANY actorDisplays.imageHash", to: contentHash)
  }

  private func isLinked(_ type: (some Object).Type, by keyPath: String, to contentHash: String) throws -> Bool {
    try !database.get(type).filter("\(keyPath) == %@", contentHash).isEmpty
  }

  private func remove(_ type: (some Object).Type, keys: some Sequence<String>) throws {
    try remove(keys.compactMap { try database.get(type, forPrimaryKey: $0) })
  }

  private func remove(_ rows: [some Object]) throws {
    guard !rows.isEmpty else { return }

    try database.delete(rows)
  }
}
