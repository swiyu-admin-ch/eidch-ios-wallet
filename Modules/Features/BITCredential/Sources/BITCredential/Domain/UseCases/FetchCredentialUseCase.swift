import BITActivity
import BITAnalytics
import BITAnyCredentialFormat
import BITCredentialShared
import BITJWT
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - FetchCredentialUseCaseProtocol

@Spyable
public protocol FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> CredentialProtocol
}

// MARK: - FetchCredentialUseCase

struct FetchCredentialUseCase: FetchCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> CredentialProtocol {
    let metadataJws = try await openIDRepository.fetchMetadata(from: offer.issuer)
    try await actorIdentityValidator.validate(metadataJws)
    let metadataWrapper = try CredentialIssuerMetadataWrapper(offer: offer, metadataJws: metadataJws)

    let holderBindings = try await holderBindingsGenerator(
      batchSize: metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize,
      proofTypes: metadataWrapper.selectedCredential.proofTypesSupported)
    var issuanceDPoPKeyPair: VaultKeyPair?

    do {
      let result = try await fetchAnyVerifiableCredentialUseCase(
        from: offer,
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings)
      let authorization = result.authorization
      issuanceDPoPKeyPair = authorization.dpopKeyPair

      switch result.credentials {
      case .credential(let credentials):
        if credentials.count > 1 {
          guard metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize != nil else {
            throw FetchCredentialUseCaseError.invalidCredential
          }
        }
        let authentication = try createAuthentication(from: authorization)
        return try await generateCredential(
          from: credentials,
          metadata: metadataWrapper,
          authentication: authentication,
          holderBindings: holderBindings)
      case .deferred(let deferredCredentialContext):
        let authentication = try createAuthentication(from: deferredCredentialContext.authorization)
        return try await generateDeferredCredential(
          from: deferredCredentialContext,
          authentication: authentication,
          metadata: metadataWrapper,
          holderBindings: holderBindings)
      }
    } catch {
      if let issuanceDPoPKeyPair {
        try? issuanceDPoPKeyRepository.delete(issuanceDPoPKeyPair)
      }
      let keyPairs = holderBindings.map(\.keyPair)
      do {
        try keyPairs.forEach { try credentialKeyRepository.delete($0) }
      } catch {
        analytics.log(error)
      }
      throw error
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository
  @Injected(\.holderBindingsGenerator) private var holderBindingsGenerator
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.issuanceDPoPKeyRepository) private var issuanceDPoPKeyRepository
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase
  @Injected(\.credentialGenerator) private var credentialGenerator
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase
  @Injected(\.activityService) private var activityService
  @Injected(\.mapCredentialsToKeyBindingsUseCase) private var mapCredentialsToKeyBindingsUseCase
  @Injected(\.keyBindingGenerator) private var keyBindingGenerator
  @Injected(\.actorIdentityValidator) private var actorIdentityValidator
  @Injected(\.protectedIssuanceValidator) private var protectedIssuanceValidator

  private func generateDeferredCredential(
    from deferredCredentialContext: DeferredCredentialContext,
    authentication: CredentialAuthentication,
    metadata: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]) async throws
    -> DeferredCredential
  {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadata.selectedCredential)
    let keyBindings = try holderBindings.compactMap { try keyBindingGenerator.generate(from: $0.keyPair) }
    return try await credentialGenerator.generateDeferred(
      deferredCredentialContext,
      keyBindings: keyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata,
      authentication: authentication)
  }

  private func generateCredential(
    from credentials: [AnyCredential],
    metadata: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication,
    holderBindings: [HolderBinding]) async throws
    -> VerifiableCredential
  {
    let credentialsWithKeyBindings = try mapCredentialsToKeyBindingsUseCase(
      credentials: credentials,
      keyPairs: holderBindings.map(\.keyPair))

    guard let firstCredentialWithKeyBinding = credentialsWithKeyBindings.first else {
      throw FetchCredentialUseCaseError.invalidCredential
    }
    try actorIdentityValidator.validate(
      issuerDid: firstCredentialWithKeyBinding.credential.issuer,
      metadataJws: metadata.metadataJws)
    try await protectedIssuanceValidator.validate(anyCredential: firstCredentialWithKeyBinding.credential, metadataWrapper: metadata)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: firstCredentialWithKeyBinding.credential)

    let credential = try await credentialGenerator.generate(
      for: credentialsWithKeyBindings,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadata,
      authentication: authentication)

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    return (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
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
  case invalidCredentialDid
}
