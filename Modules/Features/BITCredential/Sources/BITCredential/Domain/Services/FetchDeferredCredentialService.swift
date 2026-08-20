import BITCore
import BITCredentialShared
import BITJWT
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - FetchDeferredCredentialServiceError

enum FetchDeferredCredentialServiceError: Error {
  case missingDeferredCredentialURL
  case missingRefreshToken
}

// MARK: - FetchDeferredCredentialServiceProtocol

@Spyable
protocol FetchDeferredCredentialServiceProtocol {
  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (JWS<CredentialIssuerMetadataJWT>, FetchAnyCredentialResult.Credentials)
}

// MARK: - FetchDeferredCredentialService

struct FetchDeferredCredentialService: FetchDeferredCredentialServiceProtocol {

  // MARK: Internal

  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (JWS<CredentialIssuerMetadataJWT>, FetchAnyCredentialResult.Credentials) {
    let metadataJws = try await openIDRepository.fetchMetadata(from: deferredCredential.issuerUrl)

    try await actorIdentityValidator.validate(metadataJws)

    let result = try await fetchCredential(for: deferredCredential, metadata: metadataJws.payload.credentialIssuerMetadata)
    return (metadataJws, result)
  }

  // MARK: Private

  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator
  @Injected(\.isDPoPEnabled) private var isDPoPEnabled
  @Injected(\.keyManager) private var keyManager
  @Injected(\.openIDRepository) private var openIDRepository
  @Injected(\.actorIdentityValidator) private var actorIdentityValidator

  private func fetchCredential(for deferredCredential: DeferredCredential, metadata: CredentialIssuerMetadata) async throws -> FetchAnyCredentialResult.Credentials {
    guard let endpoint = metadata.deferredCredentialEndpoint else {
      throw FetchDeferredCredentialServiceError.missingDeferredCredentialURL
    }

    let credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadata)

    let responseEncryption = try CredentialResponseEncryption(from: credentialEncryptionContext)
    let request = DeferredCredentialRequest(
      transactionId: deferredCredential.transactionId,
      credentialResponseEncryption: responseEncryption)

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
      credentialEncryptionContext: credentialEncryptionContext)

    do {
      return try await openIDRepository.fetchCredential(with: context, deferredCredentialRequest: request)
    } catch OpenIdRepositoryError.expiredAccessToken {
      return try await refreshAccessTokenAndFetchCredential(
        deferredCredential,
        metadata: metadata,
        request: request,
        context: context,
        dpopKeyPair: dpopKeyPair)
    } catch {
      throw error
    }
  }

  private func refreshAccessTokenAndFetchCredential(
    _ deferredCredential: DeferredCredential,
    metadata: CredentialIssuerMetadata,
    request: DeferredCredentialRequest,
    context: FetchDeferredCredentialContext,
    dpopKeyPair: VaultKeyPair?) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    guard let refreshToken = deferredCredential.authentication.refreshToken else {
      throw FetchDeferredCredentialServiceError.missingRefreshToken
    }

    let configuration = try await openIDRepository.fetchOpenIdConfiguration(from: deferredCredential.issuerUrl)
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
    let refreshedContext = context.changing(\.authorization, to: mergedAuthorization)

    return try await openIDRepository.fetchCredential(with: refreshedContext, deferredCredentialRequest: request)
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
    guard dpopKeyPair != nil else {
      return nil
    }

    return try await openIDRepository.fetchNonce(from: metadata.nonceEndpoint).dpopNonce
  }

  private func fetchDPoPNonceIfNeeded(
    metadata: CredentialIssuerMetadata,
    dpopKeyPair: VaultKeyPair?) async throws
    -> String?
  {
    guard dpopKeyPair != nil else {
      return nil
    }

    return try await openIDRepository.fetchNonce(from: metadata.nonceEndpoint).dpopNonce
  }
}
