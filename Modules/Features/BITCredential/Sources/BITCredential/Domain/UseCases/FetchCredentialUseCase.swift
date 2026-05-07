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

    do {
      let result = try await fetchAnyVerifiableCredentialUseCase(
        from: offer,
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings)
      let credentials = result.credentials
      authentication = createAuthentication(from: result)

      switch credentials {
      case .credential(let credential):
        anyCredential = credential
      case .batch(let credentials):
        guard metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize != nil else {
          throw FetchCredentialUseCaseError.invalidCredential
        }
        return try await generateBatchCredential(
          from: credentials,
          metadata: metadataWrapper,
          authentication: authentication,
          holderBindings: holderBindings)
      case .deferred(let deferredCredentialContext):
        let deferredCredential = try await generateDeferredCredential(from: deferredCredentialContext, metadata: metadataWrapper, holderBindings: holderBindings)
        return (deferredCredential, nil)
      }
    } catch {
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

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol
  @Injected(\.holderBindingsGenerator) private var holderBindingsGenerator: HolderBindingsGeneratorProtocol
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.activityService) private var activityService
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase

  private func generateCredential(from anyCredential: AnyCredential, metadata: CredentialIssuerMetadataWrapper, authentication: CredentialAuthentication, holderBindings: [HolderBinding]) async throws -> (VerifiableCredential, TrustInformation?) {
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    var trustStatement: IdentityTrustStatementJWT?
    if case .trusted(let statement) = trustInformation.identity {
      trustStatement = statement
    }
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let keyBinding = try createKeyBinding(from: holderBindings.first?.keyPair)
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

  private func generateDeferredCredential(from deferredCredentialContext: DeferredCredentialContext, metadata: CredentialIssuerMetadataWrapper, holderBindings: [HolderBinding]) async throws -> DeferredCredential {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadata.selectedCredential)
    let keyBindings = try holderBindings.compactMap { try createKeyBinding(from: $0.keyPair) }
    return try credentialGenerator.generateDeferred(
      deferredCredentialContext,
      keyBindings: keyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata)
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

  private func createKeyBinding(from keyPair: VaultKeyPair?) throws -> KeyBinding? {
    try keyPair.flatMap { keyPair in
      let isHardwareKey = keyPair.options?.contains(.secureEnclave) ?? false
      let (publicKey, privateKey): (Data?, Data?) = isHardwareKey
        ? (nil, nil)
        : try keyManager.getExternalRepresentation(of: keyPair.privateKey)

      return KeyBinding(
        id: UUID(uuidString: keyPair.identifier) ?? UUID(),
        algorithm: keyPair.algorithm.rawValue,
        bindingType: isHardwareKey ? .hardware : .software,
        publicKey: publicKey,
        privateKey: privateKey)
    }
  }

  private func createAuthentication(from result: FetchAnyCredentialResult) -> CredentialAuthentication {
    CredentialAuthentication(
      accessToken: result.accessToken,
      tokenType: result.tokenType,
      refreshToken: result.refreshToken)
  }
}

// MARK: - FetchCredentialUseCaseError

public enum FetchCredentialUseCaseError: Error {
  case invalidCredential
}
