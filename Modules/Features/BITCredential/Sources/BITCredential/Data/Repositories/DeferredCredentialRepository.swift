import BITCredentialShared
import BITDataStore
import BITEntities
import Factory
import Spyable

// MARK: - DeferredCredentialRepositoryProtocol

@Spyable
public protocol DeferredCredentialRepositoryProtocol {
  @discardableResult
  func create(_ deferredCredential: DeferredCredential) async throws -> DeferredCredential
  func get(id: String) async throws -> DeferredCredential
}

// MARK: - DeferredCredentialRepository

struct DeferredCredentialRepository: DeferredCredentialRepositoryProtocol {

  // MARK: Internal

  func create(_ deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    let entity = DeferredCredentialEntity(deferredCredential)
    try database.save(entity)

    return DeferredCredential(entity)
  }

  func get(id: String) async throws -> DeferredCredential {
    let entity = try getEntity(id)
    return DeferredCredential(entity)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol

  private func getEntity(_ id: String) throws -> DeferredCredentialEntity {
    let results = try database.get(DeferredCredentialEntity.self, forPrimaryKey: id)

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
