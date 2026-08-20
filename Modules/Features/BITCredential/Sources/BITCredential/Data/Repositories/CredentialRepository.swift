import BITCredentialShared
import BITCrypto
import BITDataStore
import BITEntities
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialRepositoryProtocol

@Spyable
public protocol CredentialRepositoryProtocol {

  func count() throws -> Int
  func delete(_ id: UUID, deleteKeyPairs: Bool) async throws
  func get(id: UUID) async throws -> CredentialProtocol
  func getAll() async throws -> [any CredentialProtocol]
  func getIssuanceSummary(id: UUID) async throws -> CredentialIssuanceSummary

  // MARK: Verifiable Credential

  @discardableResult
  func update(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential
  func getAllVerifiableCredentials() async throws -> [VerifiableCredential]
  func getAllAcceptedVerifiableCredentials() async throws -> [VerifiableCredential]

  @discardableResult
  func create(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential

  // MARK: Deferred Credential

  @discardableResult
  func create(deferredCredential: DeferredCredential) async throws -> DeferredCredential

  @discardableResult
  func update(deferredCredential: DeferredCredential) async throws -> DeferredCredential
  func getAllDeferredCredentials() async throws -> [DeferredCredential]
}

extension CredentialRepositoryProtocol {
  public func delete(_ id: UUID) async throws {
    try await delete(id, deleteKeyPairs: true)
  }
}

// MARK: - CredentialRepositoryError

enum CredentialRepositoryError: Error {
  case notFound
  case unsupportedCredential
}

// MARK: - CredentialRepository

struct CredentialRepository: CredentialRepositoryProtocol {

  // MARK: Internal

  func get(id: UUID) async throws -> CredentialProtocol {
    let entity = try await getEntity(id)
    return try compute(entity)
  }

  func getIssuanceSummary(id: UUID) async throws -> CredentialIssuanceSummary {
    let entity = try await getEntity(id)
    guard let summary = CredentialIssuanceSummary(entity) else {
      throw CredentialRepositoryError.unsupportedCredential
    }
    return summary
  }

  func delete(_ id: UUID, deleteKeyPairs: Bool = true) async throws {
    let entity = try await getEntity(id)
    let images = entity.displayImages
    if deleteKeyPairs {
      deleteAssociatedKeyPairs(for: entity)
    }
    try database.delete(entity)
    try database.removeUnreferencedImages(images)
  }

  func getAll() async throws -> [any CredentialProtocol] {
    try database
      .get(CredentialEntity.self)
      .map(compute(_:))
      .sortedByDisplayOrder(using: \.self)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

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

  private func deleteAssociatedKeyPairs(for entity: CredentialEntity) {
    let verifiableKeyBindings = entity.verifiableCredential?.bundleItems.compactMap(\.keyBinding) ?? []
    let deferredKeyBindings = entity.deferredCredential.map { Array($0.keyBindings) } ?? []
    let dpopBindings = entity.authentication?.dpopBinding.flatMap { [$0] } ?? []

    for keyBinding in verifiableKeyBindings + deferredKeyBindings {
      guard let algorithm = VaultAlgorithm(rawValue: keyBinding.algorithm) else {
        continue
      }
      try? keyManager.deleteKeyPair(withIdentifier: keyBinding.id.uuidString, algorithm: algorithm)
    }

    for dpopBinding in dpopBindings {
      guard let algorithm = VaultAlgorithm(rawValue: dpopBinding.algorithm) else {
        continue
      }
      try? keyManager.deleteKeyPair(withIdentifier: dpopBinding.id.uuidString, algorithm: algorithm)
    }
  }

  private func createImages(from credential: CredentialProtocol) throws {
    let images = credential.issuerDisplays.compactMap(\.image) + credential.displays.compactMap(\.logoBase64)

    for data in images {
      let hash = ImageHasher.hash(data)

      if try database.get(ImageEntity.self, forPrimaryKey: hash) != nil {
        continue
      }

      let image = ImageEntity()
      image.imageHash = hash
      image.data = data
      try database.save(image)
    }
  }
}

// MARK: - Verifiable Credentials

extension CredentialRepository {

  func create(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    try createImages(from: verifiableCredential)
    let entity = CredentialEntity(verifiableCredential: verifiableCredential)
    try database.save(entity)
    return try VerifiableCredential(entity)
  }

  @discardableResult
  func update(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    let entity = try await getEntity(verifiableCredential.id)
    let images = entity.displayImages
    try createImages(from: verifiableCredential)
    try database.write {
      entity.setValues(from: verifiableCredential)
    }
    try database.removeUnreferencedImages(images)
    return try VerifiableCredential(entity)
  }

  func getAllVerifiableCredentials() async throws -> [VerifiableCredential] {
    try database
      .get(CredentialEntity.self)
      .filter { $0.verifiableCredential != nil }
      .map { try VerifiableCredential($0) }
      .sortedByDisplayOrder(using: \.self)
  }

  func getAllAcceptedVerifiableCredentials() async throws -> [VerifiableCredential] {
    try database
      .get(CredentialEntity.self)
      .filter { $0.verifiableCredential?.progressionState == .accepted }
      .map { try VerifiableCredential($0) }
      .sortedByDisplayOrder(using: \.self)
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
    try createImages(from: deferredCredential)
    let entity = CredentialEntity(deferredCredential: deferredCredential)
    try database.save(entity)
    return try DeferredCredential(entity)
  }

  func update(deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    let entity = try await getEntity(deferredCredential.id)
    let images = entity.displayImages
    try createImages(from: deferredCredential)
    try database.write {
      entity.setValues(from: deferredCredential)
    }
    try database.removeUnreferencedImages(images)
    return try DeferredCredential(entity)
  }

  func getAllDeferredCredentials() async throws -> [DeferredCredential] {
    try database
      .get(CredentialEntity.self)
      .filter { $0.deferredCredential != nil }
      .map { try DeferredCredential($0) }
      .sortedByDisplayOrder(using: \.self)
  }

}
