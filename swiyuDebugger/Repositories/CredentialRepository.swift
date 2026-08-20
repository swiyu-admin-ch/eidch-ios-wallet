import BITCredential
import BITCredentialShared
import Foundation

class LocalCredentialRepository: CredentialRepositoryProtocol {

  // MARK: Lifecycle

  init() {
    credentials = []
  }

  // MARK: Internal

  func count() throws -> Int {
    credentials.count
  }

  func delete(_ id: UUID, deleteKeyPairs: Bool) async throws {
    credentials.removeAll { $0.id == id }
  }

  func get(id: UUID) async throws -> any CredentialProtocol {
    guard let credential = credentials.first(where: { $0.id == id }) else {
      throw NSError(domain: "LocalCredentialRepository", code: 1)
    }
    return credential
  }

  func getAll() async throws -> [any CredentialProtocol] {
    credentials
  }

  func update(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    if let index = credentials.firstIndex(where: { ($0 as? VerifiableCredential)?.id == verifiableCredential.id }) {
      credentials[index] = verifiableCredential
      return verifiableCredential
    }
    throw NSError(domain: "LocalCredentialRepository", code: 2)
  }

  func getAllAcceptedVerifiableCredentials() async throws -> [BITCredentialShared.VerifiableCredential] {
    credentials.compactMap { $0 as? VerifiableCredential }
  }

  func getAllVerifiableCredentials() async throws -> [VerifiableCredential] {
    credentials.compactMap { $0 as? VerifiableCredential }
  }

  func create(verifiableCredential: VerifiableCredential) async throws -> VerifiableCredential {
    credentials.insert(verifiableCredential, at: 0)
    return verifiableCredential
  }

  func create(deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    credentials.insert(deferredCredential, at: 0)
    return deferredCredential
  }

  func update(deferredCredential: DeferredCredential) async throws -> DeferredCredential {
    if let index = credentials.firstIndex(where: { ($0 as? DeferredCredential)?.id == deferredCredential.id }) {
      credentials[index] = deferredCredential
      return deferredCredential
    }
    throw NSError(domain: "LocalCredentialRepository", code: 3)
  }

  func getAllDeferredCredentials() async throws -> [DeferredCredential] {
    credentials.compactMap { $0 as? DeferredCredential }
  }

  func getIssuanceSummary(id: UUID) async throws -> BITCredential.CredentialIssuanceSummary {
    let credential = try await get(id: id)
    guard let verifiableCredential = credential as? VerifiableCredential else {
      throw NSError(domain: "LocalCredentialRepository", code: 4)
    }
    return CredentialIssuanceSummary(
      issuedAt: verifiableCredential.createdAt,
      available: verifiableCredential.bundleItems.count(where: { !$0.presented }),
      total: verifiableCredential.bundleItems.count)
  }

  // MARK: Private

  private var credentials: [any CredentialProtocol]

}
