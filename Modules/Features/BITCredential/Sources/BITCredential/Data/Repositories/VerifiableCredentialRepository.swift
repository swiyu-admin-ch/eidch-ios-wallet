import BITCredentialShared
import BITDataStore
import BITEntities
import Factory
import Foundation
import Spyable

// MARK: - VerifiableCredentialRepositoryProcotol

@Spyable
public protocol VerifiableCredentialRepositoryProcotol {
  func create(_ credential: VerifiableCredential) async throws -> VerifiableCredential
  func get(id: UUID) async throws -> VerifiableCredential
  func getAll() async throws -> [VerifiableCredential]
  @discardableResult
  func update(_ credential: VerifiableCredential) async throws -> VerifiableCredential
  func delete(_ id: UUID) async throws
  func count() throws -> Int
}

// MARK: - VerifiableCredentialRepositoryError

enum VerifiableCredentialRepositoryError: Error {
  case notFound
}

// MARK: - VerifiableCredentialRepository

struct VerifiableCredentialRepository: VerifiableCredentialRepositoryProcotol {

  // MARK: Internal

  func create(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    let entity = CredentialEntity(verifiableCredential: credential)
    try database.save(entity)

    return try VerifiableCredential(entity)
  }

  func get(id: UUID) async throws -> VerifiableCredential {
    let entity = try await getEntity(id)
    return try VerifiableCredential(entity)
  }

  @discardableResult
  func update(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    let entity = try await getEntity(credential.id)
    try database.write({
      entity.setValues(from: credential)
    })

    return try VerifiableCredential(entity)
  }

  func delete(_ id: UUID) async throws {
    let entity = try await getEntity(id)
    try database.delete(entity)
  }

  func getAll() async throws -> [VerifiableCredential] {
    let results = try database.get(CredentialEntity.self)
    let entities = results
      .filter { $0.verifiableCredential != nil }
      .sorted { $0.createdAt < $1.createdAt }
    return try entities.map { try VerifiableCredential($0) }
  }

  func count() throws -> Int {
    try database.get(CredentialEntity.self)
      .filter { $0.verifiableCredential != nil }
      .count
  }

  // MARK: Private

  @Injected(\.dataStore) private var database

  private func getEntity(_ id: UUID) async throws -> CredentialEntity {
    let results = try database.get(CredentialEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw VerifiableCredentialRepositoryError.notFound }
    return entity
  }
}
