import BITActivity
import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
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
    guard deferredCredential.progressionState != .invalid, canRefreshCredential(deferredCredential) else {
      return
    }

    do {
      let (metadataResponse, anyCredentialResult) = try await fetchDeferredCredentialService(for: deferredCredential)
      switch anyCredentialResult {
      case .credential(let anyCredential):
        try await generateCredential(from: anyCredential, deferredCredential: deferredCredential, metadataResponse: metadataResponse)
      case .deferred(let deferredCredentialContext):
        try await updateDeferredCredential(deferredCredential, metadataResponse: metadataResponse, interval: deferredCredentialContext.interval)
      }
    } catch OpenIdRepositoryError.invalidCredential {
      return try await invalidateDeferredCredential(deferredCredential)
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

  @Injected(\.fetchDeferredCredentialService) private var fetchDeferredCredentialService: FetchDeferredCredentialServiceProtocol
  @Injected(\.activityService) private var activityService: ActivityServiceProtocol
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

  private func generateCredential(
    from anyCredential: AnyCredential,
    deferredCredential: DeferredCredential,
    metadataResponse: CredentialMetadataResponse) async throws
  {
    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataResponse: metadataResponse)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }

    var credential = try credentialGenerator.generate(
      for: anyCredential,
      keyBinding: deferredCredential.keyBinding,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: trustStatement)

    credential.progressionState = .unaccepted

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    try await credentialRepository.delete(deferredCredential.id)
    try await saveActivity(for: savedCredential, trustInformation: trustInformation)
    _ = try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)
  }

  private func updateDeferredCredential(
    _ deferredCredential: DeferredCredential,
    metadataResponse: CredentialMetadataResponse,
    interval: Int) async throws
  {
    let context = DeferredCredentialContext(
      transactionId: deferredCredential.transactionId,
      accessToken: deferredCredential.accessToken,
      endpoint: deferredCredential.endpoint,
      format: deferredCredential.format,
      interval: interval)

    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataResponse: metadataResponse)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadataWrapper.selectedCredential)

    var credential = try credentialGenerator.generateDeferred(
      context,
      keyBinding: deferredCredential.keyBinding,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper)
    credential.polledAt = Date()
    credential.pollingInterval = interval
    credential.id = deferredCredential.id

    try await credentialRepository.update(deferredCredential: credential)
  }

  private func createMetadataWrapper(for deferredCredential: DeferredCredential, metadataResponse: CredentialMetadataResponse) throws -> CredentialMetadataWrapper {
    guard let selectedConfigurationId = deferredCredential.selectedConfigurationId else {
      throw RefreshDeferredCredentialUseCaseError.invalidConfigurationId
    }

    do {
      return try CredentialMetadataWrapper(
        credentialConfigurationId: selectedConfigurationId,
        credentialMetadata: metadataResponse.metadata,
        rawData: metadataResponse.raw)
    } catch {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialMetadata
    }
  }

  private func saveActivity(for credential: VerifiableCredential, trustInformation: TrustInformation) async throws {
    let activity = Activity(credential: credential, trustInformation: trustInformation)
    _ = try? activityService.create(activity, credentialId: credential.id)
  }

  private func invalidateDeferredCredential(_ deferredCredential: DeferredCredential) async throws {
    var credential = deferredCredential
    credential.progressionState = .invalid

    try await credentialRepository.update(deferredCredential: credential)
  }
}

// MARK: - RefreshDeferredCredentialUseCaseError

enum RefreshDeferredCredentialUseCaseError: Error {
  case invalidConfigurationId
  case invalidCredentialMetadata
}
