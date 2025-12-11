import BITDataStore
import BITEntities
import Factory
import Foundation

// MARK: - ActivityRepository

struct ActivityRepository: ActivityRepositoryProtocol {

  // MARK: Internal

  func create(_ activity: Activity, credentialId: UUID) throws -> Activity {
    try createImages(from: activity.actorDisplays)
    let entity = CredentialActivityEntity(activity)
    try database.save(entity)
    let credential = try getCredential(for: credentialId)
    try database.write {
      credential.activities.append(entity)
    }
    return Activity(entity)
  }

  func get(_ id: UUID) throws -> Activity {
    let entity = try getEntity(id)
    return Activity(entity)
  }

  func getAll(for credentialId: UUID, limit: Int = Int.max) throws -> [Activity] {
    let credential = try getCredential(for: credentialId)
    return credential.activities
      .sorted(byKeyPath: "createdAt", ascending: false)
      .prefix(limit)
      .map(Activity.init)
  }

  func delete(_ id: UUID) throws {
    let entity = try getEntity(id)
    let images = entity.actorImages
    try database.delete(entity)
    try database.removeUnreferencedImages(images)
  }

  func deleteAll(for credentialId: UUID) throws {
    let credential = try getCredential(for: credentialId)
    let activities = Array(credential.activities)
    let images = activities.actorImages()
    try database.delete(activities)
    try database.removeUnreferencedImages(images)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database

  private func getCredential(for credentialId: UUID) throws -> CredentialEntity {
    guard let credential = try database.get(CredentialEntity.self, forPrimaryKey: credentialId) else {
      throw ActivityRepositoryError.notFound
    }
    return credential
  }

  private func getEntity(_ id: UUID) throws -> CredentialActivityEntity {
    let results = try database.get(CredentialActivityEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw ActivityRepositoryError.notFound }
    return entity
  }

  private func createImages(from actorDisplays: [ActivityActorDisplay]) throws {
    for display in actorDisplays {
      guard let data = display.image else { continue }

      let hash = ImageHasher.hash(data)

      if try database.get(ImageEntity.self, forPrimaryKey: hash) != nil { continue }

      let image = ImageEntity()
      image.imageHash = hash
      image.data = data
      try database.save(image)
    }
  }
}

// MARK: - ActivityRepositoryError

enum ActivityRepositoryError: Error {
  case notFound
  case unknownType
}
