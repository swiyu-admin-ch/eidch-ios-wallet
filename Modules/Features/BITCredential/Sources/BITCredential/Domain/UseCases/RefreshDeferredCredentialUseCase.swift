import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - RefreshDeferredCredentialUseCaseProtocol

@Spyable
public protocol RefreshDeferredCredentialUseCaseProtocol {
  func execute(for credential: DeferredCredential) async throws
  func execute(_ credentials: [DeferredCredential]) async throws
}

// MARK: - RefreshDeferredCredentialUseCase

struct RefreshDeferredCredentialUseCase: RefreshDeferredCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for credential: DeferredCredential) async throws {
    guard canRefreshCredential(credential) else {
      return
    }

    guard let endpoint = URL(string: credential.endpoint) else {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialUrl
    }

    do {
      let anyCredential = try await openIDRepository.refreshDeferredCredential(from: endpoint, transactionId: credential.transactionId, acccessToken: credential.accessToken, format: credential.format)
      try await generateCredential(from: anyCredential, and: credential)
    } catch OpenIdRepositoryError.credentialIssuancePending(let interval) {
      try await updateDeferredCredential(credential, interval: interval)
    } catch {
      throw error
    }
  }

  func execute(_ credentials: [DeferredCredential]) async throws {
    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
      for credential in credentials {
        taskGroup.addTask {
          try await execute(for: credential)
        }
      }

      try await taskGroup.waitForAll()
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService: TrustInformationServiceProtocol

  private func canRefreshCredential(_ credential: DeferredCredential) -> Bool {
    guard let polledAt = credential.polledAt else {
      return true
    }

    let interval = TimeInterval(credential.pollingInterval)
    return Date() >= polledAt.addingTimeInterval(interval)
  }

  private func updateDeferredCredential(_ deferredCredential: DeferredCredential, interval: Int) async throws {
    var credential = deferredCredential
    credential.polledAt = Date()
    credential.pollingInterval = interval

    try await credentialRepository.update(deferredCredential: credential)
  }

  private func generateCredential(from anyCredential: AnyCredential, and deferredCredential: DeferredCredential) async throws {
    guard
      let selectedConfigurationId = deferredCredential.selectedConfigurationId,
      let rawOIDMetadata = deferredCredential.rawCredentialData?.rawOIDMetadata,
      let metadata = try? JSONDecoder().decode(CredentialMetadata.self, from: rawOIDMetadata)
    else {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialMetadata
    }

    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)

    var credential = try credentialGenerator.generate(
      for: anyCredential,
      keyBinding: deferredCredential.keyBinding,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: CredentialMetadataWrapper(
        selectedCredentialSupportedId: selectedConfigurationId,
        credentialMetadata: metadata,
        rawData: rawOIDMetadata))

    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)

    if case .trusted(let trustStatement) = trustInformation.identity {
      credential = try await updateCredentialIssuerDisplays(credential: credential, with: trustStatement)
    }

    credential.progressionState = .unaccepted

    try await credentialRepository.create(verifiableCredential: credential)
    try await credentialRepository.delete(deferredCredential.id)
  }

  private func updateCredentialIssuerDisplays(credential: VerifiableCredential, with trustStatement: any LocalizedTrustStatement) async throws -> VerifiableCredential {
    var credentialCopy = credential

    credentialCopy.issuerDisplays = credentialCopy.issuerDisplays.compactMap { issuerDisplay in
      guard let locale = issuerDisplay.locale else { return nil }
      let entityNames = trustStatement.entityNames
      return CredentialIssuerDisplay(
        id: issuerDisplay.id,
        locale: issuerDisplay.locale,
        name: entityNames[locale] ?? issuerDisplay.name,
        credentialId: issuerDisplay.credentialId,
        image: issuerDisplay.image)
    }

    return credentialCopy
  }
}

// MARK: - RefreshDeferredCredentialUseCaseError

enum RefreshDeferredCredentialUseCaseError: Error {
  case invalidCredentialUrl
  case invalidCredentialMetadata
}
