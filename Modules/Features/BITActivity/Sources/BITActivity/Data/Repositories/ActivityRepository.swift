import BITDataStore
import BITEntities
import Combine
import Factory
import Foundation

// MARK: - ActivityRepository

/// `CurrentValueSubject` is a Combine reference type that predates `Sendable`. The repository is
/// registered `.cached`, so the subject is deliberately shared, and Combine synchronises it internally.
struct ActivityRepository: ActivityRepositoryProtocol, @unchecked Sendable {

  // MARK: Internal

  let activityHistoryEnabledSubject = CurrentValueSubject<Bool, Never>(UserDefaults.standard.bool(forKey: activityHistoryEnabledKey))

  func create(_ activity: Activity, credentialId: UUID) throws -> UUID {
    try createImages(from: activity.actorDisplays)
    let entity = CredentialActivityEntity(activity)
    try database.save(entity)
    let credential = try getCredential(for: credentialId)
    try database.write {
      snapshot(credential, into: entity)
      credential.activities.append(entity)
    }
    return entity.id
  }

  func getDetail(_ id: UUID) throws -> ActivityDetail {
    let entity = try getEntity(id)
    return try activityDetailFactory(entity)
  }

  func getAll(for credentialId: UUID, limit: Int = Int.max) throws -> [ActivityListItem] {
    let credential = try getCredential(for: credentialId)
    return credential.activities
      .sorted(by: \.createdAt, ascending: false)
      .prefix(limit)
      .map(activityListItemFactory.callAsFunction)
  }

  func delete(_ id: UUID) throws {
    let entity = try getEntity(id)
    let candidates = OrphanCandidates(entity)
    try database.delete(entity)
    try databaseCleaner.deleteOrphans(among: candidates)
  }

  func deleteAll() throws {
    let activities = try database.get(CredentialActivityEntity.self)
    try database.delete(activities)
    try databaseCleaner.deleteAllOrphans()
  }

  func isActivityHistoryEnabled() throws -> Bool {
    UserDefaults.standard.bool(forKey: Self.activityHistoryEnabledKey)
  }

  func setActivityHistoryEnabled(_ isEnabled: Bool) throws {
    UserDefaults.standard.set(isEnabled, forKey: Self.activityHistoryEnabledKey)
    activityHistoryEnabledSubject.send(isEnabled)
  }

  // MARK: Private

  private static let activityHistoryEnabledKey = "isActivityHistoryEnabled"

  @Injected(\.dataStore) private var database
  @Injected(\.databaseCleaner) private var databaseCleaner
  @Injected(\.activityListItemFactory) private var activityListItemFactory
  @Injected(\.activityDetailFactory) private var activityDetailFactory

  private func getCredential(for credentialId: UUID) throws -> CredentialEntity {
    guard let credential = try database.get(CredentialEntity.self, forPrimaryKey: credentialId) else {
      throw ActivityRepositoryError.notFound
    }
    return credential
  }

  private func snapshot(_ credential: CredentialEntity, into entity: CredentialActivityEntity) {
    entity.credentialRendering = credential.credentialRendering
    entity.rawCredentialData = credential.rawCredentialData
    entity.issuer = credential.verifiableCredential?.issuer ?? ""
  }

  private func getEntity(_ id: UUID) throws -> CredentialActivityEntity {
    let results = try database.get(CredentialActivityEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw ActivityRepositoryError.notFound }
    return entity
  }

  private func createImages(from actorDisplays: [ActivityActorDisplay]) throws {
    for display in actorDisplays {
      guard let data = display.image else { continue }

      let image = ImageEntity(data)

      if try database.get(ImageEntity.self, forPrimaryKey: image.contentHash) != nil { continue }

      try database.save(image)
    }
  }
}

// MARK: - ActivityRepositoryError

enum ActivityRepositoryError: Error {
  case notFound
  case unknownType
}
