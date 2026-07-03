import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - RefreshVerifiableCredentialUseCaseProtocol

@Spyable
public protocol RefreshVerifiableCredentialUseCaseProtocol {
  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential
}

// MARK: - RefreshVerifiableCredentialUseCase

struct RefreshVerifiableCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    let metadataResponse = try await fetchMetadata(for: credential)
    let metadataWrapper = try createMetadataWrapper(for: credential, metadataResponse: metadataResponse)
    let holderBindings = try await holderBindingsGenerator(from: metadataWrapper)
    let dpopKeyPair = try resolveDPoPKeyPair(for: credential)
    let authorization = IssuanceAuthorization(
      accessToken: AccessToken(
        accessToken: credential.authentication.accessToken,
        tokenType: credential.authentication.tokenType,
        refreshToken: credential.authentication.refreshToken),
      dpopKeyPair: dpopKeyPair)
    let result = try await refreshAnyVerifiableCredentialUseCase(
      metadataWrapper: metadataWrapper,
      holderBindings: holderBindings,
      authorization: authorization)
    let authentication = try createAuthentication(from: result.authorization)

    switch result.credentials {
    case .credential(let anyCredential):
      let keyBinding = try keyBindingGenerator.generate(from: holderBindings.first?.keyPair)
      return try await refreshCredential(
        from: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: keyBinding)],
        currentCredential: credential,
        metadataWrapper: metadataWrapper,
        authentication: authentication)

    case .batch(let credentials):
      let credentialsWithKeyBindings = try mapBatchCredentialsToKeyBindings(
        credentials,
        holderBindings: holderBindings)
      return try await refreshCredential(
        from: credentialsWithKeyBindings,
        currentCredential: credential,
        metadataWrapper: metadataWrapper,
        authentication: authentication)

    case .deferred:
      throw RefreshVerifiableCredentialUseCaseError.deferredCredentialResponseNotSupported
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.refreshAnyVerifiableCredentialUseCase) private var refreshAnyVerifiableCredentialUseCase: RefreshAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.holderBindingsGenerator) private var holderBindingsGenerator: HolderBindingsGeneratorProtocol
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService: TrustInformationServiceProtocol
  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocol
  @Injected(\.keyBindingGenerator) private var keyBindingGenerator: KeyBindingGeneratorProtocol
  @Injected(\.isDPoPEnabled) private var isDPoPEnabled: Bool

  private func fetchMetadata(for credential: VerifiableCredential) async throws -> CredentialIssuerMetadataResponse {
    guard let issuerUrl = URL(string: credential.issuerUrl) else {
      throw RefreshVerifiableCredentialUseCaseError.invalidIssuerUrl
    }

    return try await openIDRepository.fetchMetadata(from: issuerUrl)
  }

  private func createMetadataWrapper(
    for credential: VerifiableCredential,
    metadataResponse: CredentialIssuerMetadataResponse) throws
    -> CredentialIssuerMetadataWrapper
  {
    guard let selectedConfigurationId = credential.selectedConfigurationId else {
      throw RefreshVerifiableCredentialUseCaseError.invalidConfigurationId
    }

    do {
      return try CredentialIssuerMetadataWrapper(
        credentialConfigurationId: selectedConfigurationId,
        credentialIssuerMetadata: metadataResponse.metadata,
        rawData: metadataResponse.raw)
    } catch {
      throw RefreshVerifiableCredentialUseCaseError.invalidCredentialIssuerMetadata
    }
  }

  private func resolveAlgorithm(from keyBinding: KeyBinding) throws -> VaultAlgorithm {
    do {
      return try VaultAlgorithm(fromSignatureAlgorithm: keyBinding.algorithm)
    } catch {
      throw RefreshVerifiableCredentialUseCaseError.invalidKeyBinding
    }
  }

  private func createAuthentication(from authorization: IssuanceAuthorization) throws
    -> CredentialAuthentication
  {
    let dpopBinding = try keyBindingGenerator.generate(from: authorization.dpopKeyPair)

    return CredentialAuthentication(
      accessToken: authorization.accessToken.accessToken,
      tokenType: authorization.accessToken.tokenType,
      refreshToken: authorization.accessToken.refreshToken,
      dpopBinding: dpopBinding)
  }

  private func refreshCredential(
    from credentialsWithKeyBindings: [CredentialWithKeyBinding],
    currentCredential: VerifiableCredential,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication) async throws
    -> VerifiableCredential
  {
    guard let firstCredentialWithKeyBinding = credentialsWithKeyBindings.first else {
      throw RefreshVerifiableCredentialUseCaseError.invalidBatchCredentials
    }

    let anyCredential = firstCredentialWithKeyBinding.credential
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let trustInformation = await trustInformationService.fetch(
      for: anyCredential.issuer,
      type: .issuance,
      vcSchemaId: anyCredential.vcSchemaId)

    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }

    let generatedCredential = try credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: trustStatement,
      authentication: authentication)

    let updatedCredential = VerifiableCredential(
      id: currentCredential.id,
      createdAt: currentCredential.createdAt,
      refreshedAt: Date(),
      progressionState: currentCredential.progressionState,
      bundleItems: generatedCredential.bundleItems,
      nextPresentableBundleItemId: generatedCredential.nextPresentableBundleItemId,
      clusters: generatedCredential.clusters,
      format: generatedCredential.format,
      issuerUrl: generatedCredential.issuerUrl,
      selectedConfigurationId: generatedCredential.selectedConfigurationId,
      issuer: generatedCredential.issuer,
      batchData: generatedCredential.batchData,
      authentication: authentication,
      rawCredentialData: generatedCredential.rawCredentialData,
      issuerDisplays: generatedCredential.issuerDisplays,
      displays: generatedCredential.displays,
      validFrom: generatedCredential.validFrom,
      validUntil: generatedCredential.validUntil)

    let savedCredential = try await credentialRepository.update(verifiableCredential: updatedCredential)
    currentCredential.keyBindings.forEach(deleteKeyBinding)
    return (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
  }

  private func mapBatchCredentialsToKeyBindings(
    _ credentials: [AnyCredential],
    holderBindings: [HolderBinding]) throws
    -> [CredentialWithKeyBinding]
  {
    guard !holderBindings.isEmpty else {
      throw RefreshVerifiableCredentialUseCaseError.invalidBatchCredentials
    }

    return try mapCredentialsToKeyBindingsUseCase.execute(
      credentials: credentials,
      keyPairs: holderBindings.map(\.keyPair))
  }

  private func deleteKeyBinding(_ keyBinding: KeyBinding) {
    guard let algorithm = try? resolveAlgorithm(from: keyBinding) else {
      return
    }

    try? keyManager.deleteKeyPair(withIdentifier: keyBinding.id.uuidString, algorithm: algorithm)
  }

  private func resolveDPoPKeyPair(for credential: VerifiableCredential) throws -> VaultKeyPair? {
    guard isDPoPEnabled else {
      return nil
    }

    guard let dpopBinding = credential.authentication.dpopBinding else {
      return nil
    }

    let algorithm = try resolveAlgorithm(from: dpopBinding)
    return try keyManager.getKeyPair(withIdentifier: dpopBinding.id.uuidString, algorithm: algorithm)
  }
}

// MARK: - RefreshVerifiableCredentialUseCaseError

enum RefreshVerifiableCredentialUseCaseError: Error, Equatable {
  case invalidIssuerUrl
  case invalidConfigurationId
  case invalidCredentialIssuerMetadata
  case invalidKeyBinding
  case invalidBatchCredentials
  case deferredCredentialResponseNotSupported
}
