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
      case .batch(let credentials):
        try await generateBatchCredential(from: credentials, deferredCredential: deferredCredential, metadataResponse: metadataResponse)
      case .deferred(let deferredCredentialContext):
        try await updateDeferredCredential(deferredCredential, metadataResponse: metadataResponse, context: deferredCredentialContext)
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
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocol

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
    metadataResponse: CredentialIssuerMetadataResponse) async throws
  {
    let credentialWithKeyBinding = CredentialWithKeyBinding(
      credential: anyCredential,
      keyBinding: deferredCredential.keyBindings.first)
    try await generateCredential(
      from: [credentialWithKeyBinding],
      deferredCredential: deferredCredential,
      metadataResponse: metadataResponse)
  }

  private func generateCredential(
    from credentialsWithKeyBindings: [CredentialWithKeyBinding],
    deferredCredential: DeferredCredential,
    metadataResponse: CredentialIssuerMetadataResponse) async throws
  {
    guard let firstCredentialWithKeyBinding = credentialsWithKeyBindings.first else {
      throw RefreshDeferredCredentialUseCaseError.invalidBatchCredentials
    }

    let anyCredential = firstCredentialWithKeyBinding.credential
    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataResponse: metadataResponse)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }

    var credential = try credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: trustStatement,
      authentication: deferredCredential.authentication)

    credential.progressionState = .unaccepted

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    try await credentialRepository.delete(deferredCredential.id)
    try await saveActivity(for: savedCredential, trustInformation: trustInformation)
    _ = try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)
  }

  private func generateBatchCredential(
    from credentials: [AnyCredential],
    deferredCredential: DeferredCredential,
    metadataResponse: CredentialIssuerMetadataResponse) async throws
  {
    let credentialsWithKeyBindings = try mapBatchCredentialsToKeyBindings(
      credentials,
      deferredKeyBindings: deferredCredential.keyBindings)

    try await generateCredential(
      from: credentialsWithKeyBindings,
      deferredCredential: deferredCredential,
      metadataResponse: metadataResponse)
  }

  private func mapBatchCredentialsToKeyBindings(_ credentials: [AnyCredential], deferredKeyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding] {
    guard !deferredKeyBindings.isEmpty else {
      throw RefreshDeferredCredentialUseCaseError.invalidBatchCredentials
    }

    return try mapCredentialsToKeyBindingsUseCase.execute(
      credentials: credentials,
      keyBindings: deferredKeyBindings)
  }

  private func updateDeferredCredential(
    _ deferredCredential: DeferredCredential,
    metadataResponse: CredentialIssuerMetadataResponse,
    context: DeferredCredentialContext) async throws
  {
    guard deferredCredential.transactionId == context.transactionId else {
      var invalidCredential = deferredCredential
      invalidCredential.progressionState = .invalid

      try await credentialRepository.update(deferredCredential: invalidCredential)
      return
    }

    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataResponse: metadataResponse)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadataWrapper.selectedCredential)

    var credential = try credentialGenerator.generateDeferred(
      context,
      keyBindings: deferredCredential.keyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper)
    credential.polledAt = Date()
    credential.pollingInterval = context.interval
    credential.id = deferredCredential.id

    try await credentialRepository.update(deferredCredential: credential)
  }

  private func createMetadataWrapper(for deferredCredential: DeferredCredential, metadataResponse: CredentialIssuerMetadataResponse) throws -> CredentialIssuerMetadataWrapper {
    guard let selectedConfigurationId = deferredCredential.selectedConfigurationId else {
      throw RefreshDeferredCredentialUseCaseError.invalidConfigurationId
    }

    do {
      return try CredentialIssuerMetadataWrapper(
        credentialConfigurationId: selectedConfigurationId,
        credentialIssuerMetadata: metadataResponse.metadata,
        rawData: metadataResponse.raw)
    } catch {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialIssuerMetadata
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
  case invalidBatchCredentials
  case invalidConfigurationId
  case invalidCredentialIssuerMetadata
}
