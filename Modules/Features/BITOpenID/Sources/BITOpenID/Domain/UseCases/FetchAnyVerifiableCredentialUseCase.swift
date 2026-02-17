import BITAnyCredentialFormat
import BITJWT
import BITNetworking
import BITVault
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
  case unsupportedKeyStorage
}

// MARK: - FetchAnyVerifiableCredentialUseCaseProtocol

@Spyable
public protocol FetchAnyVerifiableCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer, metadataWrapper: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> FetchAnyCredentialResult
}

// MARK: - FetchAnyVerifiableCredentialUseCase

struct FetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer, metadataWrapper: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> FetchAnyCredentialResult {
    let credentialEndpoint = try getCredentialEndpoint(from: metadataWrapper)
    let issuerUrl = try getIssuerUrl(from: offer)
    let configuration = try await repository.fetchOpenIdConfiguration(from: issuerUrl)
    let accessToken = try await fetchAccessToken(tokenEndpoint: configuration.tokenEndpoint, credentialOffer: offer)
    let nonce = if let nonceString = accessToken.nonce {
      Nonce(cNonce: nonceString)
    } else {
      try await fetchNonceIfNeeded(from: metadataWrapper, holderBindingContext: holderBindingContext)
    }

    let context = FetchCredentialContext(
      credentialConfigurationId: metadataWrapper.credentialConfigurationId,
      format: metadataWrapper.selectedCredential.format,
      selectedCredential: metadataWrapper.selectedCredential,
      credentialIssuer: metadataWrapper.credentialMetadata.credentialIssuer,
      holderBindingContext: holderBindingContext,
      accessToken: accessToken,
      nonce: nonce,
      credentialEndpoint: credentialEndpoint,
      deferredCredentialEndpoint: metadataWrapper.credentialMetadata.deferredCredentialEndpoint)

    guard let credentialFormat = CredentialFormat(rawValue: context.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try await dispatcherFormat.execute(for: context)
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]

  private func getCredentialEndpoint(from metadata: CredentialMetadataWrapper) throws -> URL {
    guard
      let credentialEndpoint = URL(string: metadata.credentialMetadata.credentialEndpoint),
      credentialEndpoint.isValidHttpUrl
    else {
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

  private func fetchAccessToken(tokenEndpoint: URL, credentialOffer: CredentialOffer) async throws -> AccessToken {
    do {
      return try await repository.fetchAccessToken(from: tokenEndpoint, preAuthorizedCode: credentialOffer.preAuthorizedCode)
    } catch {
      guard let err = error as? NetworkError, err.status == .invalidGrant else { throw error }
      throw FetchAnyVerifiableCredentialError.expiredInvitation
    }
  }

  private func fetchNonceIfNeeded(from metadataWrapper: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> Nonce? {
    guard holderBindingContext != nil else { return nil }

    if let nonceEndpoint = metadataWrapper.credentialMetadata.nonceEndpoint {
      return try await repository.fetchNonce(from: nonceEndpoint)
    }
    return nil
  }
}
