import BITCredentialShared
import BITDataStore
import BITEntities
import Factory
import Foundation
import Spyable

// MARK: - DeferredCredentialRepositoryProtocol

@Spyable
public protocol DeferredCredentialRepositoryProtocol {
  @discardableResult
  func create(_ credential: DeferredCredential) async throws -> DeferredCredential
  func get(id: UUID) async throws -> DeferredCredential
}

// MARK: - DeferredCredentialRepository

struct DeferredCredentialRepository: DeferredCredentialRepositoryProtocol {

  // MARK: Internal

  func create(_ credential: DeferredCredential) async throws -> DeferredCredential {
    let entity = CredentialEntity(deferredCredential: credential)
    try database.save(entity)

    return try DeferredCredential(entity)
  }

  func get(id: UUID) async throws -> DeferredCredential {
    let entity = try getEntity(id)
    return try DeferredCredential(entity)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol

  private func getEntity(_ id: UUID) throws -> CredentialEntity {
    let results = try database.get(CredentialEntity.self, forPrimaryKey: id)

    guard let entity = results else {
      throw DeferredCredentialRepositoryError.notFound
    }

    return entity
  }
}

// MARK: - DeferredCredentialRepositoryError

enum DeferredCredentialRepositoryError: Error {
  case notFound
}
