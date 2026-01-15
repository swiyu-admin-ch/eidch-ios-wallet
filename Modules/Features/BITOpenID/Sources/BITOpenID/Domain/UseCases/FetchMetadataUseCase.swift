import Factory
import Foundation
import Spyable

// MARK: - FetchMetadataUseCaseProtocol

@Spyable
public protocol FetchMetadataUseCaseProtocol {
  func execute(for offer: CredentialOffer) async throws -> CredentialMetadataWrapper
}

// MARK: - FetchMetadataUseCase

struct FetchMetadataUseCase: FetchMetadataUseCaseProtocol {

  // MARK: Internal

  func execute(for offer: CredentialOffer) async throws -> CredentialMetadataWrapper {
    let issuerUrl = try getIssuerUrl(from: offer)
    let response = try await openIDRepository.fetchMetadata(from: issuerUrl)
    return try await createWrapper(from: response, offer: offer)
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var openIDRepository: OpenIDRepositoryProtocol

  private func createWrapper(from response: CredentialMetadataResponse, offer: CredentialOffer) async throws -> CredentialMetadataWrapper {
    guard let selectedCredentialId = offer.credentialConfigurationIds.first else {
      throw FetchAnyVerifiableCredentialError.selectedCredentialNotFound
    }

    return try CredentialMetadataWrapper(credentialConfigurationId: selectedCredentialId, credentialMetadata: response.metadata, rawData: response.raw)
  }

  private func getIssuerUrl(from offer: CredentialOffer) throws -> URL {
    guard let issuerUrl = URL(string: offer.issuer) else {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    }
    return issuerUrl
  }
}
