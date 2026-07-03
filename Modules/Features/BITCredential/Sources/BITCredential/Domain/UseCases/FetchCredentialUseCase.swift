import BITActivity
import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - FetchCredentialUseCaseProtocol

@Spyable
public protocol FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> (CredentialProtocol, TrustInformation?)
}

// MARK: - FetchCredentialUseCase

struct FetchCredentialUseCase: FetchCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> (CredentialProtocol, TrustInformation?) {
    let metadataWrapper = try await fetchMetadataUseCase.execute(for: offer)
    let holderBindings = try await holderBindingsGenerator(from: metadataWrapper)
    let anyCredential: AnyCredential
    let authentication: CredentialAuthentication
    var issuanceDPoPKeyPair: VaultKeyPair?

    do {
      let result = try await fetchAnyVerifiableCredentialUseCase(
        from: offer,
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings)
      let authorization = result.authorization
      issuanceDPoPKeyPair = authorization.dpopKeyPair

      switch result.credentials {
      case .credential(let credential):
        authentication = try createAuthentication(from: authorization)
        anyCredential = credential

      case .batch(let credentials):
        guard metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize != nil else {
          throw FetchCredentialUseCaseError.invalidCredential
        }

        let authentication = try createAuthentication(from: authorization)
        return try await generateBatchCredential(
          from: credentials,
          metadata: metadataWrapper,
          authentication: authentication,
          holderBindings: holderBindings)

      case .deferred(let deferredCredentialContext):
        let authentication = try createAuthentication(from: deferredCredentialContext.authorization)
        let deferredCredential = try await generateDeferredCredential(
          from: deferredCredentialContext,
          authentication: authentication,
          metadata: metadataWrapper,
          holderBindings: holderBindings)
        return (deferredCredential, nil)
      }
    } catch {
      if let issuanceDPoPKeyPair {
        try? issuanceDPoPKeyRepository.delete(issuanceDPoPKeyPair)
      }
      try holderBindings.map(\.keyPair).forEach { keyPair in
        try credentialKeyRepository.delete(keyPair)
      }
      throw error
    }

    return try await generateCredential(
      from: anyCredential,
      metadata: metadataWrapper,
      authentication: authentication,
      holderBindings: holderBindings)
  }

  // MARK: Private

  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol
  @Injected(\.holderBindingsGenerator) private var holderBindingsGenerator: HolderBindingsGeneratorProtocol
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.issuanceDPoPKeyRepository) private var issuanceDPoPKeyRepository: IssuanceDPoPKeyRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.activityService) private var activityService
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase
  @Injected(\.keyBindingGenerator) private var keyBindingGenerator: KeyBindingGeneratorProtocol

  private func generateCredential(
    from anyCredential: AnyCredential,
    metadata: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication,
    holderBindings: [HolderBinding]) async throws
    -> (VerifiableCredential, TrustInformation?)
  {
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let keyBinding = try keyBindingGenerator.generate(from: holderBindings.first?.keyPair)
    let credentialWithKeyBinding = CredentialWithKeyBinding(credential: anyCredential, keyBinding: keyBinding)

    let credential = try credentialGenerator.generate(
      for: [credentialWithKeyBinding],
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata,
      trustStatement: trustStatement,
      authentication: authentication)

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    let activity = Activity(credential: savedCredential, trustInformation: trustInformation)
    _ = try? activityService.create(activity, credentialId: savedCredential.id)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    return (updatedCredential, trustInformation)
  }

  private func generateDeferredCredential(
    from deferredCredentialContext: DeferredCredentialContext,
    authentication: CredentialAuthentication,
    metadata: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]) async throws
    -> DeferredCredential
  {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadata.selectedCredential)
    let keyBindings = try holderBindings.compactMap { try keyBindingGenerator.generate(from: $0.keyPair) }
    return try credentialGenerator.generateDeferred(
      deferredCredentialContext,
      keyBindings: keyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata,
      authentication: authentication)
  }

  private func generateBatchCredential(
    from credentials: [AnyCredential],
    metadata: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication,
    holderBindings: [HolderBinding]) async throws
    -> (VerifiableCredential, TrustInformation?)
  {
    let credentialsWithKeyBindings = try mapCredentialsToKeyBindingsUseCase.execute(
      credentials: credentials,
      keyPairs: holderBindings.map(\.keyPair))

    guard let firstCredentialWithKeyBinding = credentialsWithKeyBindings.first else {
      throw FetchCredentialUseCaseError.invalidCredential
    }

    let trustInformation = await trustInformationService.fetch(
      for: firstCredentialWithKeyBinding.credential.issuer,
      type: .issuance,
      vcSchemaId: firstCredentialWithKeyBinding.credential.vcSchemaId)

    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: firstCredentialWithKeyBinding.credential)

    let credential = try credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata,
      trustStatement: trustStatement,
      authentication: authentication)

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    let activity = Activity(credential: savedCredential, trustInformation: trustInformation)
    _ = try? activityService.create(activity, credentialId: savedCredential.id)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    return (updatedCredential, trustInformation)
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
}

// MARK: - FetchCredentialUseCaseError

public enum FetchCredentialUseCaseError: Error {
  case invalidCredential
}
