import BITAnyCredentialFormat
import BITAppAttestation
import BITAppAuth
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
  case expiredInvitation
  case validationFailed
  case missingTypeMetadata
  case invalidVcSchema
  case vctMismatch
  case missingVctIntegrity
  case unsupportedKeyStorage
}

// MARK: - FetchAnyVerifiableCredentialUseCaseProtocol

@Spyable
public protocol FetchAnyVerifiableCredentialUseCaseProtocol {
  func callAsFunction(
    from offer: CredentialOffer,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?) async throws
    -> FetchAnyCredentialResult
}

// MARK: - FetchAnyVerifiableCredentialUseCase

struct FetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(
    from offer: CredentialOffer,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBindings: [HolderBinding]?) async throws
    -> FetchAnyCredentialResult
  {
    let credentialEndpoint = try getCredentialEndpoint(from: metadataWrapper)
    let issuerUrl = try getIssuerUrl(from: offer)
    let configuration = try await repository.fetchOpenIdConfiguration(from: issuerUrl)
    let issuanceDPoPKeyPair = isDPoPEnabled ? try createIssuanceDPoPKeyPair(
      from: configuration,
      holderBindings: holderBindings) : nil

    do {
      let firstHolderBinding = holderBindings?.first
      let tokenRequestDPoPNonce = try await fetchTokenRequestDPoPNonceIfNeeded(
        from: metadataWrapper,
        dpopKeyPair: issuanceDPoPKeyPair)
      let tokenRequestDPoPKeyAttestationJWS = try await fetchDPoPKeyAttestationIfNeeded(
        for: issuanceDPoPKeyPair)
      let authorization = try await fetchAccessToken(
        tokenEndpoint: configuration.tokenEndpoint,
        credentialOffer: offer,
        dpopKeyPair: issuanceDPoPKeyPair,
        dpopNonce: tokenRequestDPoPNonce,
        dpopKeyAttestationJWS: tokenRequestDPoPKeyAttestationJWS)
      let credentialRequestNonce = try await fetchCredentialRequestNonceIfNeeded(
        from: metadataWrapper,
        holderBinding: firstHolderBinding,
        dpopKeyPair: issuanceDPoPKeyPair)

      let credentialEncryptionContext = try credentialEncryptionContextGenerator(for: metadataWrapper.credentialIssuerMetadata)

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

      guard let credentialFormat = CredentialFormat(rawValue: context.format), let dispatcherFormat = dispatcher[credentialFormat] else {
        throw CredentialFormatError.formatNotSupported
      }

      let credentials = try await dispatcherFormat.execute(for: context)
      return FetchAnyCredentialResult(
        credentials: credentials,
        authorization: authorization)
    } catch {
      if let issuanceDPoPKeyPair {
        try? issuanceDPoPKeyRepository.delete(issuanceDPoPKeyPair)
      }
      throw error
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]
  @Injected(\.credentialEncryptionContextGenerator) private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocol
  @Injected(\.issuanceDPoPKeyRepository) private var issuanceDPoPKeyRepository: IssuanceDPoPKeyRepositoryProtocol
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.supportedDPoPSigningAlgorithms) private var supportedDPoPSigningAlgorithms: [JWTAlgorithm]
  @Injected(\.isDPoPEnabled) private var isDPoPEnabled: Bool

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

  private func fetchAccessToken(
    tokenEndpoint: URL,
    credentialOffer: CredentialOffer,
    dpopKeyPair: VaultKeyPair?,
    dpopNonce: String?,
    dpopKeyAttestationJWS: String?) async throws
    -> IssuanceAuthorization
  {
    do {
      return try await repository.fetchAccessToken(
        from: tokenEndpoint,
        preAuthorizedCode: credentialOffer.preAuthorizedCode,
        dpopKeyPair: dpopKeyPair,
        dpopNonce: dpopNonce,
        dpopKeyAttestationJWS: dpopKeyAttestationJWS)
    } catch {
      if let err = error as? NetworkError, err.status == .invalidGrant {
        throw FetchAnyVerifiableCredentialError.expiredInvitation
      }
      if case .invalidGrant = error as? OpenIdRepositoryError {
        throw FetchAnyVerifiableCredentialError.expiredInvitation
      }
      throw error
    }
  }

  private func createIssuanceDPoPKeyPair(
    from configuration: OpenIdConfiguration,
    holderBindings: [HolderBinding]?) throws
    -> VaultKeyPair?
  {
    guard isDPoPEnabled else {
      return nil
    }

    let supportedAlgorithms = supportedDPoPSigningAlgorithms.map(\.rawValue)
    guard configuration.supportsDPoP(for: supportedAlgorithms) else {
      return nil
    }

    let isHardwareBound = holderBindings?.contains(where: { $0.keyPair.options?.contains(.secureEnclave) == true }) ?? false
    return try issuanceDPoPKeyRepository.create(isHardwareBound: isHardwareBound)
  }

  private func fetchTokenRequestDPoPNonceIfNeeded(
    from metadataWrapper: CredentialIssuerMetadataWrapper,
    dpopKeyPair: VaultKeyPair?) async throws
    -> String?
  {
    guard dpopKeyPair != nil, let nonceEndpoint = metadataWrapper.credentialIssuerMetadata.nonceEndpoint else {
      return nil
    }

    return try? await repository.fetchNonce(from: nonceEndpoint).dpopNonce
  }

  private func fetchDPoPKeyAttestationIfNeeded(for keyPair: VaultKeyPair?) async throws -> String? {
    guard let keyPair, keyPair.options?.contains(.secureEnclave) == true else {
      return nil
    }

    guard let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }

    let clientAttestation = try await clientAttestationRepository.get(using: context)
    let requestBody = try KeyAttestationRequestBody(keyPair: keyPair)
    let keyAttestation = try await appAttestationRepository.fetchKeyAttestation(
      body: requestBody,
      clientAttestation: clientAttestation)

    guard await keyAttestationValidator(keyPair: keyPair, with: keyAttestation) else {
      throw AppAttestationRepositoryError.invalidKeyAttestation
    }

    return keyAttestation.rawJWS
  }

  private func fetchCredentialRequestNonceIfNeeded(
    from metadataWrapper: CredentialIssuerMetadataWrapper,
    holderBinding: HolderBinding?,
    dpopKeyPair: VaultKeyPair?) async throws
    -> (nonce: Nonce, dpopNonce: String?)?
  {
    // https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7
    guard holderBinding != nil || dpopKeyPair != nil else {
      return nil
    }

    if let nonceEndpoint = metadataWrapper.credentialIssuerMetadata.nonceEndpoint {
      return try await repository.fetchNonce(from: nonceEndpoint)
    }
    return nil
  }
}
