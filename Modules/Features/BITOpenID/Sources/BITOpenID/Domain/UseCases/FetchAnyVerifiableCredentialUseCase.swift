import BITAnalytics
import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - FetchAnyVerifiableCredentialError

public enum FetchAnyVerifiableCredentialError: Error {
  case unsupportedAlgorithm
  case credentialEndpointCreationError
  case expiredInvitation
  case selectedCredentialNotFound
  case unknownIssuer
  case validationFailed
  case missingTypeMetadata
  case typeMetadataInvalidIntegrity
  case invalidVcSchema
  case vctMismatch
  case missingVctIntegrity
}

// MARK: - FetchAnyVerifiableCredentialUseCaseProtocol

public typealias CredentialBundle = (metadataWrapper: CredentialMetadataWrapper, anyCredential: AnyCredential, keyPair: KeyPair?)

// MARK: - FetchAnyVerifiableCredentialUseCaseProtocol

@Spyable
public protocol FetchAnyVerifiableCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> CredentialBundle
}

// MARK: - FetchAnyVerifiableCredentialUseCase

struct FetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> CredentialBundle {
    let metadataWrapper = try await fetchMetadata(from: offer)
    let credentialEndpoint = try getCredentialEndpoint(from: metadataWrapper)

    let keyPair = try generateHolderBindingKeyPair(from: metadataWrapper)

    let issuerUrl = try getIssuerUrl(from: offer)
    let configuration = try await repository.fetchOpenIdConfiguration(from: issuerUrl)
    let accessToken = try await fetchAccessToken(
      considering: nil,
      tokenEndpoint: configuration.tokenEndpoint,
      credentialOffer: offer)

    let context = FetchCredentialContext(
      format: metadataWrapper.selectedCredential.format,
      selectedCredential: metadataWrapper.selectedCredential,
      credentialOffers: offer.credentialConfigurationIds,
      credentialIssuer: metadataWrapper.credentialMetadata.credentialIssuer,
      keyPair: keyPair,
      accessToken: accessToken,
      credentialEndpoint: credentialEndpoint)

    let anyCredential = try await fetchAnyCredentialUseCase.execute(for: context)
    return (metadataWrapper, anyCredential, keyPair)
  }

  // MARK: Private

  @Injected(\.fetchAnyCredentialUseCase) private var fetchAnyCredentialUseCase: FetchAnyCredentialUseCaseProtocol
  @Injected(\.credentialKeyPairGenerator) private var keyPairGenerator: CredentialKeyPairGeneratorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.preferredKeyBindingAlgorithmsOrdered) private var preferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm]
  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol

  private func getCredentialEndpoint(from metadata: CredentialMetadataWrapper) throws -> URL {
    guard
      let credentialEndpoint = URL(string: metadata.credentialMetadata.credentialEndpoint),
      credentialEndpoint.isValidHttpUrl else
    {
      throw FetchAnyVerifiableCredentialError.credentialEndpointCreationError
    }

    return credentialEndpoint
  }

  private func getIssuerUrl(from offer: CredentialOffer) throws -> URL {
    guard let issuerUrl = URL(string: offer.issuer) else {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    }
    return issuerUrl
  }

  private func fetchMetadata(from offer: CredentialOffer) async throws -> CredentialMetadataWrapper {
    let issuerUrl = try getIssuerUrl(from: offer)

    guard let selectedCredentialId = offer.credentialConfigurationIds.first else {
      throw FetchAnyVerifiableCredentialError.selectedCredentialNotFound
    }

    let response = try await fetchMetadataUseCase.execute(from: issuerUrl)
    return try CredentialMetadataWrapper(selectedCredentialSupportedId: selectedCredentialId, credentialMetadata: response.object, rawData: response.data)
  }

  private func fetchAccessToken(considering accessToken: AccessToken?, tokenEndpoint: URL, credentialOffer: CredentialOffer) async throws -> AccessToken {
    if let accessToken {
      return accessToken
    }
    do {
      return try await repository.fetchAccessToken(from: tokenEndpoint, preAuthorizedCode: credentialOffer.preAuthorizedCode)
    } catch {
      guard let err = error as? NetworkError, err.status == .invalidGrant else { throw error }
      throw FetchAnyVerifiableCredentialError.expiredInvitation
    }
  }

  private func generateHolderBindingKeyPair(from metadataWrapper: CredentialMetadataWrapper) throws -> KeyPair? {
    guard let supportedAlgorithms = metadataWrapper.selectedCredential.proofTypesSupported.first?.algorithms else {
      return nil
    }

    let preferredAlgorithms = preferredKeyBindingAlgorithmsOrdered.map(\.rawValue)
    guard let algorithm = preferredAlgorithms.first(where: { supportedAlgorithms.contains($0) }) else {
      throw FetchAnyVerifiableCredentialError.unsupportedAlgorithm
    }

    do {
      return try keyPairGenerator.generate(identifier: UUID(), algorithm: algorithm)
    } catch {
      analytics.log(error)
      throw error
    }
  }
}
