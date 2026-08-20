import BITAnyCredentialFormat
import BITCredentialShared
import BITJWT
import BITOpenID
import BITSdJWT
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
      let (metadataJws, anyCredentialResult) = try await fetchDeferredCredentialService(for: deferredCredential)
      switch anyCredentialResult {
      case .credential(let credentials):
        try await generateCredential(from: credentials, deferredCredential: deferredCredential, metadataJws: metadataJws)
      case .deferred(let deferredCredentialContext):
        try await updateDeferredCredential(deferredCredential, metadataJws: metadataJws, context: deferredCredentialContext)
      }
    } catch OpenIdRepositoryError.invalidCredential {
      return try await updateState(for: deferredCredential, to: .invalid)
    } catch {
      return try await updateState(for: deferredCredential, to: .issuanceFailed)
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
  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocol
  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.actorIdentityValidator) private var actorIdentityValidator
  @Injected(\.protectedIssuanceValidator) private var protectedIssuanceValidator: ProtectedIssuanceValidatorProtocol

  private func canRefreshCredential(_ credential: DeferredCredential) -> Bool {
    guard let polledAt = credential.polledAt else {
      return true
    }

    let interval = TimeInterval(credential.pollingInterval)
    return Date() >= polledAt.addingTimeInterval(interval)
  }

  private func generateCredential(
    from credentials: [AnyCredential],
    deferredCredential: DeferredCredential,
    metadataJws: JWS<CredentialIssuerMetadataJWT>) async throws
  {
    let credentialsWithKeyBindings = try mapBatchCredentialsToKeyBindings(
      credentials,
      deferredKeyBindings: deferredCredential.keyBindings)
    guard let firstCredentialWithKeyBinding = credentialsWithKeyBindings.first else {
      throw RefreshDeferredCredentialUseCaseError.invalidBatchCredentials
    }

    let anyCredential = firstCredentialWithKeyBinding.credential
    try actorIdentityValidator.validate(issuerDid: anyCredential.issuer, metadataJws: metadataJws)

    guard let vcSdJWS = anyCredential as? VcSdJWS else {
      throw FetchAnyVerifiableCredentialError.validationFailed
    }

    try await jwsSignatureValidator.validate(vcSdJWS)

    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataJws: metadataJws)
    try await protectedIssuanceValidator.validate(anyCredential: anyCredential, metadataWrapper: metadataWrapper)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)

    var credential = try await credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      authentication: deferredCredential.authentication)

    credential.progressionState = .unaccepted

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    try await credentialRepository.delete(deferredCredential.id, deleteKeyPairs: false)
    _ = try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)
  }

  private func mapBatchCredentialsToKeyBindings(_ credentials: [AnyCredential], deferredKeyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding] {
    guard !deferredKeyBindings.isEmpty else {
      throw RefreshDeferredCredentialUseCaseError.invalidBatchCredentials
    }

    return try mapCredentialsToKeyBindingsUseCase(
      credentials: credentials,
      keyBindings: deferredKeyBindings)
  }

  private func updateDeferredCredential(
    _ deferredCredential: DeferredCredential,
    metadataJws: JWS<CredentialIssuerMetadataJWT>,
    context: DeferredCredentialContext) async throws
  {
    guard deferredCredential.transactionId == context.transactionId else {
      var invalidCredential = deferredCredential
      invalidCredential.progressionState = .invalid

      try await credentialRepository.update(deferredCredential: invalidCredential)
      return
    }

    let metadataWrapper = try createMetadataWrapper(for: deferredCredential, metadataJws: metadataJws)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadataWrapper.selectedCredential)
    let authentication = CredentialAuthentication(
      accessToken: context.accessToken.accessToken,
      tokenType: context.accessToken.tokenType,
      refreshToken: context.accessToken.refreshToken,
      dpopBinding: deferredCredential.authentication.dpopBinding)

    var credential = try await credentialGenerator.generateDeferred(
      context,
      keyBindings: deferredCredential.keyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      authentication: authentication)
    credential.polledAt = Date()
    credential.pollingInterval = context.interval
    credential.id = deferredCredential.id

    try await credentialRepository.update(deferredCredential: credential)
  }

  private func createMetadataWrapper(for deferredCredential: DeferredCredential, metadataJws: JWS<CredentialIssuerMetadataJWT>) throws -> CredentialIssuerMetadataWrapper {
    guard let selectedConfigurationId = deferredCredential.selectedConfigurationId else {
      throw RefreshDeferredCredentialUseCaseError.invalidConfigurationId
    }

    do {
      return try CredentialIssuerMetadataWrapper(credentialConfigurationId: selectedConfigurationId, metadataJws: metadataJws)
    } catch {
      throw RefreshDeferredCredentialUseCaseError.invalidCredentialIssuerMetadata
    }
  }

  private func updateState(for deferredCredential: DeferredCredential, to state: DeferredCredential.ProgressionState) async throws {
    var credential = deferredCredential
    credential.progressionState = state

    try await credentialRepository.update(deferredCredential: credential)
  }
}

// MARK: - RefreshDeferredCredentialUseCaseError

enum RefreshDeferredCredentialUseCaseError: Error {
  case invalidBatchCredentials
  case invalidConfigurationId
  case invalidCredentialIssuerMetadata
  case invalidCredentialDid
}
