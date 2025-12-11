import BITCredentialShared
import BITDataStore
import BITEntities
import Factory
import Foundation
import Spyable

// MARK: - CredentialRepositoryProcotol

@Spyable
public protocol CredentialRepositoryProcotol {

  func count() throws -> Int
  func delete(_ id: UUID) async throws
  func get(id: UUID) async throws -> CredentialProtocol
  func getAll() async throws -> [any CredentialProtocol]

  // MARK: Verifiable Credential

  @discardableResult
  func update(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential
  func getAllVerifiableCredentials() async throws -> [VerifiableCredential]

  @discardableResult
  func create(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential

  // MARK: Deferred Credential

  @discardableResult
  func create(deferredCredential: DeferredCredential) async throws -> DeferredCredential

  @discardableResult
  func update(deferredCredential: DeferredCredential) async throws -> DeferredCredential
}

// MARK: - CredentialRepositoryError

enum CredentialRepositoryError: Error {
  case notFound
  case unsupportedCredential
}

// MARK: - CredentialRepository

struct CredentialRepository: CredentialRepositoryProcotol {

  // MARK: Internal

  func get(id: UUID) async throws -> CredentialProtocol {
    let entity = try await getEntity(id)
    return try compute(entity)
  }

  func delete(_ id: UUID) async throws {
    let entity = try await getEntity(id)
    try database.delete(entity)
  }

  func getAll() async throws -> [any CredentialProtocol] {
    let results = try database.get(CredentialEntity.self)
    let entities = results
      .sorted { $0.createdAt < $1.createdAt }

    return try entities.map(compute(_:))
  }

  // MARK: Private

  @Injected(\.dataStore) private var database

  private func getEntity(_ id: UUID) async throws -> CredentialEntity {
    let results = try database.get(CredentialEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw CredentialRepositoryError.notFound }
    return entity
  }

  private func compute(_ entity: CredentialEntity) throws -> any CredentialProtocol {
    if let verifiableCredential = try? VerifiableCredential(entity) {
      return verifiableCredential
    }

    if let deferredCredential = try? DeferredCredential(entity) {
      return deferredCredential
    }

    throw CredentialRepositoryError.unsupportedCredential
  }
}

// MARK: - Verifiable Credentials

extension CredentialRepository {

  func create(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    let entity = CredentialEntity(verifiableCredential: verifiableCredential)
    try database.save(entity)
    return try VerifiableCredential(entity)
  }

  @discardableResult
  func update(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    let entity = try await getEntity(verifiableCredential.id)
    try database.write({
      entity.setValues(from: verifiableCredential)
    })

    return try VerifiableCredential(entity)
  }

  func getAllVerifiableCredentials() async throws -> [VerifiableCredential] {
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
}

// MARK: - Deferred Credentials

extension CredentialRepository {

  func create(deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    let entity = CredentialEntity(deferredCredential: deferredCredential)
    try database.save(entity)
    return try DeferredCredential(entity)
  }

  func update(deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    let entity = try await getEntity(deferredCredential.id)
    try database.write({
      entity.setValues(from: deferredCredential)
    })

    return try DeferredCredential(entity)
  }

}
