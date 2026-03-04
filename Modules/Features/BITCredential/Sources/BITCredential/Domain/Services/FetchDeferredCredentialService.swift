import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - FetchDeferredCredentialServiceError

enum FetchDeferredCredentialServiceError: Error {
  case invalidIssuerUrl
  case missingDeferredCredentialURL
}

// MARK: - FetchDeferredCredentialServiceProtocol

@Spyable
protocol FetchDeferredCredentialServiceProtocol {
  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (CredentialMetadataResponse, FetchAnyCredentialResult)
}

// MARK: - FetchDeferredCredentialService

struct FetchDeferredCredentialService: FetchDeferredCredentialServiceProtocol {

  // MARK: Internal

  func callAsFunction(for deferredCredential: DeferredCredential) async throws -> (CredentialMetadataResponse, FetchAnyCredentialResult) {
    let metadataResponse = try await fetchMetadata(for: deferredCredential)
    let result = try await fetchCredential(for: deferredCredential, metadata: metadataResponse.metadata)
    return (metadataResponse, result)
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol
  @Injected(\.deferredCredentialRequestBodyGenerator) private var deferredCredentialRequestBodyGenerator: DeferredCredentialRequestBodyGeneratorProtocol

  private func fetchMetadata(for deferredCredential: DeferredCredential) async throws -> CredentialMetadataResponse {
    guard let issuerUrl = URL(string: deferredCredential.issuerUrl) else {
      throw FetchDeferredCredentialServiceError.invalidIssuerUrl
    }

    return try await openIDRepository.fetchMetadata(from: issuerUrl)
  }

  private func fetchCredential(for deferredCredential: DeferredCredential, metadata: CredentialMetadata) async throws -> FetchAnyCredentialResult {
    guard let endpoint = metadata.deferredCredentialEndpoint else {
      throw FetchDeferredCredentialServiceError.missingDeferredCredentialURL
    }

    let credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadata)
    let requestBody = try deferredCredentialRequestBodyGenerator.generate(
      transactionId: deferredCredential.transactionId,
      credentialEncryptionContext: credentialEncryptionContext)

    return try await openIDRepository.fetchCredential(
      from: endpoint,
      requestBody: requestBody,
      accessToken: deferredCredential.accessToken,
      format: deferredCredential.format,
      privateKey: credentialEncryptionContext?.responseKeyPair?.privateKey)
  }
}
