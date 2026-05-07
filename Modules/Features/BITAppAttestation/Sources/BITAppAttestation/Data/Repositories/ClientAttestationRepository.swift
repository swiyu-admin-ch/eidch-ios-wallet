import BITCrypto
import BITDataStore
import BITEntities
import BITJWT
import BITLocalAuthentication
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - ClientAttestationRepositoryProtocol

@Spyable
public protocol ClientAttestationRepositoryProtocol {
  func get(using context: LAContextProtocol) async throws -> ClientAttestation
  func create(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation
  func delete() throws
}

// MARK: - ClientAttestationRepository

struct ClientAttestationRepository: ClientAttestationRepositoryProtocol {

  // MARK: Internal

  func get(using context: LAContextProtocol) async throws -> ClientAttestation {
    do {
      let cached = try getCached()

      guard
        !cached.payload.isExpired,
        await clientAttestationValidator(cached) else
      {
        try delete()
        return try await fetchAndStore(using: context)
      }

      return cached
    } catch ClientAttestationRepositoryError.notFound {
      return try await fetchAndStore(using: context)
    }
  }

  func create(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation {
    let entity = ClientAttestationEntity(clientAttestation)
    try database.save(entity)
    return try ClientAttestation(entity)
  }

  func delete() throws {
    let entity = try getLastEntity()
    try database.delete(entity)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol
  @Injected(\.appAttestationProvider) private var appAttestationProvider: AppAttestationProviderProtocol
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.clientAttestationValidator) private var clientAttestationValidator: ClientAttestationValidatorProtocol

  private func getLastEntity() throws -> ClientAttestationEntity {
    guard
      let entity = try database.get(ClientAttestationEntity.self)
        .sorted(by: \.createdAt)
        .last
    else {
      throw ClientAttestationRepositoryError.notFound
    }

    return entity
  }

  private func getCached() throws -> ClientAttestation {
    let entity = try getLastEntity()
    return try ClientAttestation(entity)
  }

  private func fetchAndStore(using context: LAContextProtocol) async throws -> ClientAttestation {
    let clientAttestation = try await fetchClientAttestation(context)
    return try await saveClientAttestation(clientAttestation)
  }

  private func saveClientAttestation(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation {
    guard await clientAttestationValidator(clientAttestation) else {
      throw ClientAttestationRepositoryError.invalidClientAttestation
    }

    return try await create(clientAttestation)
  }

  private func fetchClientAttestation(_ context: LAContextProtocol) async throws -> ClientAttestation {
    let challenge = try await appAttestationRepository.fetchChallenge()
    let appAttestedKey = try await appAttestationProvider.generateAttestedKey(with: challenge)
    let keyPair = try appAttestationKeyRepository.create(for: .client, with: context)

    let clientData = try createClientData(challenge: challenge, keyPair: keyPair)
    let appAssertion = try await appAttestationProvider.generateAppAssertion(for: appAttestedKey.identifier, with: clientData)

    let requestBody = ClientAttestationRequestBody(
      appAttestation: appAttestedKey.clientData.base64EncodedString(),
      appAssertion: appAssertion.base64EncodedString(),
      clientData: clientData)

    return try await appAttestationRepository.fetchClientAttestation(requestBody)
  }

  private func createClientData(challenge: AttestationChallenge, keyPair: VaultKeyPair) throws -> ClientDataObject {
    guard let publicKey = keyPair.publicKey, let jwk = try? JWK(from: publicKey) else {
      throw ClientAttestationRepositoryError.invalidBindingKey
    }

    return ClientDataObject(challenge: challenge, bindingKey: BindingKey(jwk: jwk))
  }

}

// MARK: - ClientAttestationRepositoryError

enum ClientAttestationRepositoryError: Error {
  case notFound
  case invalidBindingKey
  case invalidClientAttestation
}
