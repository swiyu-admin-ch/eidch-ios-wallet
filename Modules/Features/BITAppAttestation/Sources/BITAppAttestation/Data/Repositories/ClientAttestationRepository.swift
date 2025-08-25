import BITDataStore
import BITEntities
import Factory
import Spyable

// MARK: - ClientAttestationRepositoryProtocol

@Spyable
public protocol ClientAttestationRepositoryProtocol {
  func get() async throws -> ClientAttestation
  func create(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation
}

// MARK: - ClientAttestationRepository

struct ClientAttestationRepository: ClientAttestationRepositoryProtocol {

  // MARK: Internal

  func create(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation {
    let entity = ClientAttestationEntity(clientAttestation)
    try database.save(entity)
    return try ClientAttestation(entity)
  }

  func get() async throws -> ClientAttestation {
    guard
      let entity = try database.get(ClientAttestationEntity.self)
        .sorted(by: \.createdAt)
        .last
    else {
      throw ClientAttestationRepositoryError.notFound
    }

    return try ClientAttestation(entity)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol
}

// MARK: - ClientAttestationRepositoryError

enum ClientAttestationRepositoryError: Error {
  case notFound
}
