import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - FetchDeferredCredentialServiceError

enum FetchDeferredCredentialServiceError: Error {
  case invalidIssuerUrl
  case missingDeferredCredentialURL
  case missingRefreshToken
}

// MARK: - FetchDeferredCredentialServiceProtocol

@Spyable
protocol FetchDeferredCredentialServiceProtocol {
  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (CredentialIssuerMetadataResponse, FetchAnyCredentialResult.Credentials)
}

// MARK: - FetchDeferredCredentialService

struct FetchDeferredCredentialService: FetchDeferredCredentialServiceProtocol {

  // MARK: Internal

  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (CredentialIssuerMetadataResponse, FetchAnyCredentialResult.Credentials) {
    let metadataResponse = try await fetchMetadata(for: deferredCredential)
    let result = try await fetchCredential(for: deferredCredential, metadata: metadataResponse.metadata)
    return (metadataResponse, result)
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol
  @Injected(\.deferredCredentialRequestBodyGenerator) private var deferredCredentialRequestBodyGenerator: DeferredCredentialRequestBodyGeneratorProtocol
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.isDPoPEnabled) private var isDPoPEnabled: Bool

  private func fetchMetadata(for deferredCredential: DeferredCredential) async throws -> CredentialIssuerMetadataResponse {
    guard let issuerUrl = URL(string: deferredCredential.issuerUrl) else {
      throw FetchDeferredCredentialServiceError.invalidIssuerUrl
    }

    return try await openIDRepository.fetchMetadata(from: issuerUrl)
  }

  private func fetchCredential(for deferredCredential: DeferredCredential, metadata: CredentialIssuerMetadata) async throws -> FetchAnyCredentialResult.Credentials {
    guard let endpoint = metadata.deferredCredentialEndpoint else {
      throw FetchDeferredCredentialServiceError.missingDeferredCredentialURL
    }

    let credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadata)

    let requestBody = try deferredCredentialRequestBodyGenerator.generate(
      transactionId: deferredCredential.transactionId,
      credentialEncryptionContext: credentialEncryptionContext)

    let authentication = deferredCredential.authentication
    let dpopKeyPair = try resolveDPoPKeyPair(for: deferredCredential)
    let resourceServerDPoPNonce = try await fetchResourceServerDPoPNonceIfNeeded(
      metadata: metadata,
      dpopKeyPair: dpopKeyPair)
    let authorization = IssuanceAuthorization(
      accessToken: AccessToken(
        accessToken: authentication.accessToken,
        tokenType: authentication.tokenType,
        refreshToken: authentication.refreshToken),
      dpopKeyPair: dpopKeyPair,
      resourceServerDPoPNonce: resourceServerDPoPNonce)
    let context = FetchDeferredCredentialContext(
      format: deferredCredential.format,
      authorization: authorization,
      deferredCredentialEndpoint: endpoint,
      privateKey: credentialEncryptionContext?.responseKeyPair?.privateKey)

    do {
      return try await openIDRepository.fetchCredential(with: context, requestBody: requestBody)
    } catch OpenIdRepositoryError.expiredAccessToken {
      return try await refreshAccessTokenAndFetchCredential(
        deferredCredential,
        metadata: metadata,
        requestBody: requestBody,
        context: context,
        dpopKeyPair: dpopKeyPair)
    } catch {
      throw error
    }
  }

  private func refreshAccessTokenAndFetchCredential(
    _ deferredCredential: DeferredCredential,
    metadata: CredentialIssuerMetadata,
    requestBody: DeferredCredentialRequestBody,
    context: FetchDeferredCredentialContext,
    dpopKeyPair: VaultKeyPair?) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    guard let refreshToken = deferredCredential.authentication.refreshToken else {
      throw FetchDeferredCredentialServiceError.missingRefreshToken
    }

    guard let issuerURL = URL(string: deferredCredential.issuerUrl) else {
      throw FetchDeferredCredentialServiceError.invalidIssuerUrl
    }

    let configuration = try await openIDRepository.fetchOpenIdConfiguration(from: issuerURL)
    let dpopNonce = try await fetchDPoPNonceIfNeeded(
      metadata: metadata,
      dpopKeyPair: dpopKeyPair)
    let refreshedAuthorization = try await openIDRepository.refreshAccessToken(
      from: configuration.tokenEndpoint,
      refreshToken: refreshToken,
      dpopKeyPair: dpopKeyPair,
      dpopNonce: dpopNonce)
    let credentialDPoPNonce = try await fetchResourceServerDPoPNonceIfNeeded(
      metadata: metadata,
      dpopKeyPair: dpopKeyPair)
    let mergedAccessToken = AccessToken(
      accessToken: refreshedAuthorization.accessToken.accessToken,
      tokenType: refreshedAuthorization.accessToken.tokenType,
      refreshToken: refreshedAuthorization.refreshToken ?? context.authorization.refreshToken)
    let mergedAuthorization = IssuanceAuthorization(
      accessToken: mergedAccessToken,
      dpopKeyPair: refreshedAuthorization.dpopKeyPair,
      resourceServerDPoPNonce: credentialDPoPNonce)
    let refreshedContext = FetchDeferredCredentialContext(
      format: context.format,
      authorization: mergedAuthorization,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint,
      privateKey: context.privateKey)

    return try await openIDRepository.fetchCredential(with: refreshedContext, requestBody: requestBody)
  }

  private func resolveDPoPKeyPair(for deferredCredential: DeferredCredential) throws -> VaultKeyPair? {
    guard isDPoPEnabled else {
      return nil
    }

    guard
      let dpopBinding = deferredCredential.authentication.dpopBinding,
      let algorithm = VaultAlgorithm(rawValue: dpopBinding.algorithm)
    else {
      return nil
    }

    return try keyManager.getKeyPair(withIdentifier: dpopBinding.id.uuidString, algorithm: algorithm)
  }

  private func fetchResourceServerDPoPNonceIfNeeded(
    metadata: CredentialIssuerMetadata,
    dpopKeyPair: VaultKeyPair?) async throws
    -> String?
  {
    // OpenID4VCI 1.0 Section 7 allows the Credential Issuer nonce endpoint to proactively return
    // a `DPoP-Nonce` header for the next protected-resource request.
    // https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7
    guard dpopKeyPair != nil, let nonceEndpoint = metadata.nonceEndpoint else {
      return nil
    }

    return try await openIDRepository.fetchNonce(from: nonceEndpoint).dpopNonce
  }

  private func fetchDPoPNonceIfNeeded(
    metadata: CredentialIssuerMetadata,
    dpopKeyPair: VaultKeyPair?) async throws
    -> String?
  {
    guard dpopKeyPair != nil, let nonceEndpoint = metadata.nonceEndpoint else {
      return nil
    }

    return try await openIDRepository.fetchNonce(from: nonceEndpoint).dpopNonce
  }
}
