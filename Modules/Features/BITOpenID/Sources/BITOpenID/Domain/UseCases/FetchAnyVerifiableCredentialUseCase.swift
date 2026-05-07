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
  func callAsFunction(from offer: CredentialOffer, metadataWrapper: CredentialIssuerMetadataWrapper, holderBindings: [HolderBinding]?) async throws -> FetchAnyCredentialResult
}

// MARK: - FetchAnyVerifiableCredentialUseCase

struct FetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(from offer: CredentialOffer, metadataWrapper: CredentialIssuerMetadataWrapper, holderBindings: [HolderBinding]?) async throws -> FetchAnyCredentialResult {
    let credentialEndpoint = try getCredentialEndpoint(from: metadataWrapper)
    let issuerUrl = try getIssuerUrl(from: offer)
    let configuration = try await repository.fetchOpenIdConfiguration(from: issuerUrl)
    let accessToken = try await fetchAccessToken(tokenEndpoint: configuration.tokenEndpoint, credentialOffer: offer)
    let firstHolderBinding = holderBindings?.first
    let nonce = try await fetchNonceIfNeeded(from: metadataWrapper, holderBinding: firstHolderBinding)
    var credentialEncryptionContext: CredentialEncryptionContext?
    #warning("remove feature flag, once OMNI is feature ready. Per default only enabled on DEV")
    if isPayloadEncryptionEnabled {
      credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadataWrapper.credentialIssuerMetadata)
    }

    let context = FetchCredentialContext(
      credentialConfigurationId: metadataWrapper.credentialConfigurationId,
      format: metadataWrapper.selectedCredential.format,
      selectedCredential: metadataWrapper.selectedCredential,
      credentialIssuer: metadataWrapper.credentialIssuerMetadata.credentialIssuer,
      holderBindings: holderBindings,
      accessToken: accessToken,
      nonce: nonce,
      credentialEndpoint: credentialEndpoint,
      credentialEncryptionContext: credentialEncryptionContext,
      deferredCredentialEndpoint: metadataWrapper.credentialIssuerMetadata.deferredCredentialEndpoint)

    guard let credentialFormat = CredentialFormat(rawValue: context.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    let credentials = try await dispatcherFormat.execute(for: context)
    return FetchAnyCredentialResult(
      credentials: credentials,
      accessToken: accessToken.accessToken,
      tokenType: accessToken.tokenType,
      refreshToken: accessToken.refreshToken)
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol
  @Injected(\.isPayloadEncryptionEnabled) private var isPayloadEncryptionEnabled

  private func getCredentialEndpoint(from metadata: CredentialIssuerMetadataWrapper) throws -> URL {
    guard
      let credentialEndpoint = URL(string: metadata.credentialIssuerMetadata.credentialEndpoint),
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
    try await repository.fetchAccessToken(from: tokenEndpoint, preAuthorizedCode: credentialOffer.preAuthorizedCode)
  }

  private func fetchNonceIfNeeded(from metadataWrapper: CredentialIssuerMetadataWrapper, holderBinding: HolderBinding?) async throws -> Nonce? {
    guard holderBinding != nil else { return nil }

    if let nonceEndpoint = metadataWrapper.credentialIssuerMetadata.nonceEndpoint {
      return try await repository.fetchNonce(from: nonceEndpoint)
    }
    return nil
  }
}
