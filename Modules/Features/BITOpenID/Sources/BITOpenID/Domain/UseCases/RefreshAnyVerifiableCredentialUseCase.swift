import BITAnyCredentialFormat
import BITNetworking
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - RefreshAnyVerifiableCredentialUseCaseProtocol

@Spyable
public protocol RefreshAnyVerifiableCredentialUseCaseProtocol {
  func callAsFunction(
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?,
    authorization: IssuanceAuthorization) async throws
    -> FetchAnyCredentialResult
}

// MARK: - RefreshAnyVerifiableCredentialUseCase

struct RefreshAnyVerifiableCredentialUseCase: RefreshAnyVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?,
    authorization: IssuanceAuthorization) async throws
    -> FetchAnyCredentialResult
  {
    let credentialEndpoint = try getCredentialEndpoint(from: metadataWrapper)
    let credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadataWrapper.credentialIssuerMetadata)

    do {
      return try await fetchCredentialResult(
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings,
        authorization: authorization,
        credentialEndpoint: credentialEndpoint,
        credentialEncryptionContext: credentialEncryptionContext)
    } catch OpenIdRepositoryError.expiredAccessToken {
      guard let refreshToken = authorization.refreshToken else {
        throw OpenIdRepositoryError.expiredAccessToken
      }

      let refreshedAuthorization = try await refreshAccessToken(
        metadataWrapper: metadataWrapper,
        refreshToken: refreshToken,
        dpopKeyPair: authorization.dpopKeyPair)
      let updatedAuthorization = IssuanceAuthorization(
        accessToken: AccessToken(
          accessToken: refreshedAuthorization.accessToken.accessToken,
          tokenType: refreshedAuthorization.accessToken.tokenType,
          refreshToken: refreshedAuthorization.refreshToken ?? refreshToken),
        dpopKeyPair: refreshedAuthorization.dpopKeyPair ?? authorization.dpopKeyPair)

      return try await fetchCredentialResult(
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings,
        authorization: updatedAuthorization,
        credentialEndpoint: credentialEndpoint,
        credentialEncryptionContext: credentialEncryptionContext)
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol

  private func fetchCredentialResult(
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?,
    authorization: IssuanceAuthorization,
    credentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext) async throws
    -> FetchAnyCredentialResult
  {
    let credentials = try await fetchCredentials(
      metadataWrapper: metadataWrapper,
      holderBindings: holderBindings,
      authorization: authorization,
      credentialEndpoint: credentialEndpoint,
      credentialEncryptionContext: credentialEncryptionContext)

    return FetchAnyCredentialResult(
      credentials: credentials,
      authorization: authorization)
  }

  private func fetchCredentials(
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?,
    authorization: IssuanceAuthorization,
    credentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    let credentialRequestNonce = try await fetchCredentialRequestNonceIfNeeded(
      from: metadataWrapper,
      holderBinding: holderBindings?.first,
      dpopKeyPair: authorization.dpopKeyPair)

    let context = FetchCredentialContext(
      credentialConfigurationId: metadataWrapper.credentialConfigurationId,
      format: metadataWrapper.selectedCredential.format,
      selectedCredential: metadataWrapper.selectedCredential,
      credentialIssuer: metadataWrapper.credentialIssuerMetadata.credentialIssuer,
      holderBindings: holderBindings,
      authorization: IssuanceAuthorization(
        accessToken: authorization.accessToken,
        dpopKeyPair: authorization.dpopKeyPair,
        resourceServerDPoPNonce: credentialRequestNonce?.dpopNonce),
      nonce: credentialRequestNonce?.nonce,
      credentialEndpoint: credentialEndpoint,
      credentialEncryptionContext: credentialEncryptionContext,
      deferredCredentialEndpoint: metadataWrapper.credentialIssuerMetadata.deferredCredentialEndpoint)

    guard let dispatcherFormat = dispatcher[context.format] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try await dispatcherFormat.execute(for: context)
  }

  private func refreshAccessToken(
    metadataWrapper: CredentialIssuerMetadataWrapper,
    refreshToken: String,
    dpopKeyPair: VaultKeyPair?) async throws
    -> IssuanceAuthorization
  {
    let issuerUrl = metadataWrapper.credentialIssuerMetadata.credentialIssuer
    let configuration = try await repository.fetchOpenIdConfiguration(from: issuerUrl)
    let dpopNonce = try await fetchTokenRequestDPoPNonceIfNeeded(
      from: metadataWrapper,
      dpopKeyPair: dpopKeyPair)
    return try await repository.refreshAccessToken(
      from: configuration.tokenEndpoint,
      refreshToken: refreshToken,
      dpopKeyPair: dpopKeyPair,
      dpopNonce: dpopNonce)
  }

  private func getCredentialEndpoint(from metadataWrapper: CredentialIssuerMetadataWrapper) throws -> URL {
    guard
      let credentialEndpoint = URL(string: metadataWrapper.credentialIssuerMetadata.credentialEndpoint),
      credentialEndpoint.isValidHttpUrl
    else {
      throw FetchAnyVerifiableCredentialError.credentialEndpointCreationError
    }

    return credentialEndpoint
  }

  private func fetchTokenRequestDPoPNonceIfNeeded(
    from metadataWrapper: CredentialIssuerMetadataWrapper,
    dpopKeyPair: VaultKeyPair?) async throws
    -> String?
  {
    guard dpopKeyPair != nil else {
      return nil
    }

    return try await repository.fetchNonce(from: metadataWrapper.credentialIssuerMetadata.nonceEndpoint).dpopNonce
  }

  private func fetchCredentialRequestNonceIfNeeded(
    from metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBinding: HolderBinding?,
    dpopKeyPair: VaultKeyPair?) async throws
    -> (nonce: Nonce, dpopNonce: String?)?
  {
    guard holderBinding != nil || dpopKeyPair != nil else {
      return nil
    }

    return try await repository.fetchNonce(from: metadataWrapper.credentialIssuerMetadata.nonceEndpoint)
  }
}
