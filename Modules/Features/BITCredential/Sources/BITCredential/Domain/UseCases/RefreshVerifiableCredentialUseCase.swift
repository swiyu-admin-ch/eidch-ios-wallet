import BITAnalytics
import BITAnyCredentialFormat
import BITCredentialShared
import BITJWT
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
    let metadataJws = try await openIDRepository.fetchMetadata(from: credential.issuerUrl)

    try await actorIdentityValidator.validate(metadataJws)

    let metadataWrapper = try createMetadataWrapper(for: credential, metadataJws: metadataJws)
    let holderBindings = try await holderBindingsGenerator(
      batchSize: metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize,
      proofTypes: metadataWrapper.selectedCredential.proofTypesSupported)

    do {
      return try await refresh(
        credential,
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings)
    } catch {
      deleteHolderBindings(holderBindings)
      throw error
    }
  }

  // MARK: Private

  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase
  @Injected(\.holderBindingsGenerator) private var holderBindingsGenerator
  @Injected(\.isDPoPEnabled) private var isDPoPEnabled
  @Injected(\.keyBindingGenerator) private var keyBindingGenerator
  @Injected(\.keyManager) private var keyManager
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase
  @Injected(\.openIDRepository) private var openIDRepository
  @Injected(\.actorIdentityValidator) private var actorIdentityValidator
  @Injected(\.protectedIssuanceValidator) private var protectedIssuanceValidator
  @Injected(\.refreshAnyVerifiableCredentialUseCase) private var refreshAnyVerifiableCredentialUseCase
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.analytics) private var analytics

  private func refresh(
    _ credential: VerifiableCredential,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]) async throws
    -> VerifiableCredential
  {
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
    case .credential(let credentials):
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

  private func createMetadataWrapper(
    for credential: VerifiableCredential,
    metadataJws: JWS<CredentialIssuerMetadataJWT>) throws
    -> CredentialIssuerMetadataWrapper
  {
    guard let selectedConfigurationId = credential.selectedConfigurationId else {
      throw RefreshVerifiableCredentialUseCaseError.invalidConfigurationId
    }
    return try CredentialIssuerMetadataWrapper(credentialConfigurationId: selectedConfigurationId, metadataJws: metadataJws)
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
    try actorIdentityValidator.validate(
      issuerDid: firstCredentialWithKeyBinding.credential.issuer,
      metadataJws: metadataWrapper.metadataJws)

    let anyCredential = firstCredentialWithKeyBinding.credential
    try await protectedIssuanceValidator.validate(anyCredential: anyCredential, metadataWrapper: metadataWrapper)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)

    let generatedCredential = try await credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
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

    return try mapCredentialsToKeyBindingsUseCase(
      credentials: credentials,
      keyPairs: holderBindings.map(\.keyPair))
  }

  private func deleteKeyBinding(_ keyBinding: KeyBinding) {
    guard let algorithm = try? resolveAlgorithm(from: keyBinding) else {
      return
    }

    try? keyManager.deleteKeyPair(withIdentifier: keyBinding.id.uuidString, algorithm: algorithm)
  }

  private func deleteHolderBindings(_ holderBindings: [HolderBinding]) {
    let keyPairs = holderBindings.map(\.keyPair)
    do {
      try keyPairs.forEach { try credentialKeyRepository.delete($0) }
    } catch {
      analytics.log(error)
    }
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
  case invalidCredentialDid
}
