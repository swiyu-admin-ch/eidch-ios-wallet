import BITCredentialShared
import BITOpenID
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

  @Injected(\.isPayloadEncryptionEnabled) private var isPayloadEncryptionEnabled
  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol
  @Injected(\.deferredCredentialRequestBodyGenerator) private var deferredCredentialRequestBodyGenerator: DeferredCredentialRequestBodyGeneratorProtocol

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

    var credentialEncryptionContext: CredentialEncryptionContext?
    #warning("remove feature flag, once OMNI is feature ready. Per default only enabled on DEV")
    if isPayloadEncryptionEnabled {
      credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadata)
    }

    let requestBody = try deferredCredentialRequestBodyGenerator.generate(
      transactionId: deferredCredential.transactionId,
      credentialEncryptionContext: credentialEncryptionContext)

    let context = FetchDeferredCredentialContext(
      format: deferredCredential.format,
      accessToken: deferredCredential.authentication.accessToken,
      deferredCredentialEndpoint: endpoint,
      privateKey: credentialEncryptionContext?.responseKeyPair?.privateKey,
      refreshToken: deferredCredential.authentication.refreshToken)

    do {
      return try await openIDRepository.fetchCredential(with: context, requestBody: requestBody)
    } catch OpenIdRepositoryError.expiredAccessToken {
      return try await refreshAccessTokenAndFetchCredential(deferredCredential, context: context, requestBody: requestBody)
    } catch {
      throw error
    }
  }

  private func refreshAccessTokenAndFetchCredential(
    _ deferredCredential: DeferredCredential,
    context: FetchDeferredCredentialContext,
    requestBody: DeferredCredentialRequestBody) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    guard let refreshToken = deferredCredential.authentication.refreshToken else {
      throw FetchDeferredCredentialServiceError.missingRefreshToken
    }

    guard let issuerURL = URL(string: deferredCredential.issuerUrl) else {
      throw FetchDeferredCredentialServiceError.invalidIssuerUrl
    }

    let configuration = try await openIDRepository.fetchOpenIdConfiguration(from: issuerURL)
    let accessToken = try await openIDRepository.refreshAccessToken(from: configuration.tokenEndpoint, refreshToken: refreshToken)
    context.updateTokens(from: accessToken)

    return try await openIDRepository.fetchCredential(with: context, requestBody: requestBody)
  }
}
