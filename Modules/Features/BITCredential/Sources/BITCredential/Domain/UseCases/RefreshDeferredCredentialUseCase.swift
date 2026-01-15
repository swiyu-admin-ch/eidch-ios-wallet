import BITActivity
import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - RefreshDeferredCredentialUseCaseProtocol

@Spyable
protocol RefreshDeferredCredentialUseCaseProtocol {
  func execute(for credential: DeferredCredential) async throws
  func execute(_ credentials: [DeferredCredential]) async throws
}

// MARK: - RefreshDeferredCredentialUseCase

struct RefreshDeferredCredentialUseCase: RefreshDeferredCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for deferredCredential: DeferredCredential) async throws {
    guard canRefreshCredential(deferredCredential) else {
      return
    }

    guard let endpoint = URL(string: deferredCredential.endpoint) else {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialUrl
    }

    let result = try await openIDRepository.fetchCredential(from: endpoint, transactionId: deferredCredential.transactionId, accessToken: deferredCredential.accessToken, format: deferredCredential.format)

    switch result {
    case .credential(let anyCredential):
      try await generateCredential(from: anyCredential, and: deferredCredential)
    case .deferred(let deferredCredentialRequest):
      try await updateDeferredCredential(deferredCredential, interval: deferredCredentialRequest.interval)
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

  @Injected(\.activityService) private var activityService: ActivityServiceProtocol
  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService: TrustInformationServiceProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol

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
        credentialConfigurationId: selectedConfigurationId,
        credentialMetadata: metadata,
        rawData: rawOIDMetadata))

    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)

    if case .trusted(let trustStatement) = trustInformation.identity {
      credential = try await updateCredentialIssuerDisplays(credential: credential, with: trustStatement)
    }

    credential.progressionState = .unaccepted

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    try await credentialRepository.delete(deferredCredential.id)
    try await saveActivity(for: savedCredential, trustInformation: trustInformation)
    _ = try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)
  }

  private func updateCredentialIssuerDisplays(credential: VerifiableCredential, with trustStatement: IdentityTrustStatementJWT) async throws -> VerifiableCredential {
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

  private func saveActivity(for credential: VerifiableCredential, trustInformation: TrustInformation) async throws {
    let activity = Activity(credential: credential, trustInformation: trustInformation)
    _ = try? activityService.create(activity, credentialId: credential.id)
  }
}

// MARK: - RefreshDeferredCredentialUseCaseError

enum RefreshDeferredCredentialUseCaseError: Error {
  case invalidCredentialUrl
  case invalidCredentialMetadata
}
