import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITNetworking
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class FetchAnyVerifiableCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    success()

    useCase = FetchAnyVerifiableCredentialUseCase()
  }

  func testExecute_validArguments_createsValidContextAndFetches() async throws {
    mockAnyCredential.raw = UUID().uuidString

    let execution = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    if case .credential(let credential) = execution.credentials {
      XCTAssertEqual(mockAnyCredential.raw, credential.raw)
    }
    XCTAssertEqual(execution.authorization.accessToken.accessToken, mockAccessToken.accessToken)
    XCTAssertEqual(execution.authorization.accessToken.tokenType, .bearer)
    XCTAssertEqual(execution.authorization.accessToken.refreshToken, mockAccessToken.refreshToken)
    XCTAssertEqual(execution.authorization.dpopKeyPair?.identifier, issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)

    XCTAssertEqual(repository.fetchOpenIdConfigurationFromCallsCount, 1)
    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundReceivedIsHardwareBound, true)
    XCTAssertEqual(repository.fetchNonceFromCallsCount, 2)
    XCTAssertEqual(repository.fetchNonceFromReceivedUrl, mockMetadataWrapper.credentialIssuerMetadata.nonceEndpoint)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSCallsCount, 1)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.url, mockOpenIdConfiguration.tokenEndpoint)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyPair?.identifier, issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopNonce, Self.mockTokenRequestDPoPNonce)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyAttestationJWS, mockKeyAttestation.rawJWS)
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 1)

    guard let receivedContext = spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext else {
      XCTFail("receivedContext must not be nil")
      return
    }

    XCTAssertEqual(credentialEncryptionContextGeneratorSpy.callAsFunctionForCallsCount, 1)
    XCTAssertEqual(receivedContext.format, mockMetadataWrapper.selectedCredential.format)
    XCTAssertEqual(
      receivedContext.selectedCredential as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported,
      mockMetadataWrapper.selectedCredential as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(receivedContext.credentialIssuer, mockMetadataWrapper.credentialIssuerMetadata.credentialIssuer)
    XCTAssertEqual(receivedContext.holderBindings, mockHolderBindings)
    XCTAssertEqual(receivedContext.dpopKeyPair?.identifier, issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
    XCTAssertEqual(receivedContext.accessToken, mockAccessToken)
    XCTAssertEqual(receivedContext.nonce, mockNonce)
    XCTAssertEqual(receivedContext.dpopNonce, Self.mockCredentialRequestDPoPNonce)
    XCTAssertEqual(receivedContext.credentialEndpoint.absoluteString, mockMetadataWrapper.credentialIssuerMetadata.credentialEndpoint)
    XCTAssertEqual(receivedContext.credentialEncryptionContext, mockCredentialEncryptionContext)
    XCTAssertEqual(receivedContext.deferredCredentialEndpoint, mockMetadataWrapper.credentialIssuerMetadata.deferredCredentialEndpoint)

    XCTAssertEqual(spyFetchCredentialVcSdJwtUseCase.executeForCallsCount, 1)
  }

  func testExecute_metadataInvalidEndpoint_throws() async throws {
    try await testCredentialEndpointInvalid(endpoint: "")
    try await testCredentialEndpointInvalid(endpoint: "1234")
    try await testCredentialEndpointInvalid(endpoint: "abc/cde")
  }

  func testExecute_offerInvalidIssuer_throws() async {
    let offer = CredentialOffer(issuer: "", grants: Grants(urn: Urn(preAuthorizedCode: "")), credentialConfigurationIds: [])

    do {
      _ = try await useCase(from: offer, metadataWrapper: mockMetadataWrapper, holderBindings: [])
      XCTFail("Expected error")
    } catch FetchAnyVerifiableCredentialError.unknownIssuer {
      XCTAssertEqual(repository.fetchOpenIdConfigurationFromCallsCount, 0)
    } catch {
      XCTFail("Expected unknownIssuer, but got \(error)")
    }
  }

  func testExecute_fetchOpenIDConfigurationThrows_throws() async {
    repository.fetchOpenIdConfigurationFromThrowableError = TestingError.error

    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: [])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchAccessTokenThrowsInvalidGrant_throws() async {
    repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSThrowableError = OpenIdRepositoryError.invalidGrant("invalid_grant")

    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.expiredInvitation {
      XCTAssertEqual(repository.fetchOpenIdConfigurationFromCallsCount, 1)
      XCTAssertEqual(repository.fetchNonceFromCallsCount, 1)
      XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSCallsCount, 1)
      XCTAssertEqual(repository.fetchCredentialWithCredentialRequestCallsCount, 0)
      XCTAssertEqual(repository.fetchIssuerPublicKeyInfoFromCallsCount, 0)
      XCTAssertEqual(spyFetchCredentialVcSdJwtUseCase.executeForCallsCount, 0)
    } catch {
      XCTFail("Not the expected error")
    }
  }

  func testExecute_tokenRequestNonceFetchThrows_fallsBackToRequestWithoutDPoPNonce() async throws {
    var fetchNonceCallCount = 0
    repository.fetchNonceFromClosure = { _ in
      fetchNonceCallCount += 1
      if fetchNonceCallCount == 1 {
        throw NetworkError(status: .serviceUnavailable)
      }
      return (self.mockNonce, Self.mockCredentialRequestDPoPNonce)
    }

    let execution = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    XCTAssertEqual(repository.fetchNonceFromCallsCount, 2)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopNonce)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyAttestationJWS, mockKeyAttestation.rawJWS)
    XCTAssertEqual(spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext?.dpopNonce, Self.mockCredentialRequestDPoPNonce)
    XCTAssertEqual(execution.authorization.dpopKeyPair?.identifier, issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
  }

  func testExecute_credentialRequestNonceFetchThrows_throws() async {
    var fetchNonceCallCount = 0
    repository.fetchNonceFromClosure = { _ in
      fetchNonceCallCount += 1
      if fetchNonceCallCount == 2 {
        throw NetworkError(status: .notFound)
      }
      return (self.mockNonce, Self.mockTokenRequestDPoPNonce)
    }

    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)
      XCTFail("An error was expected")
    } catch {
      guard error as? NetworkError != nil else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSCallsCount, 1)
      XCTAssertEqual(repository.fetchCredentialWithCredentialRequestCallsCount, 0)
      XCTAssertEqual(repository.fetchIssuerPublicKeyInfoFromCallsCount, 0)
      XCTAssertEqual(spyFetchCredentialVcSdJwtUseCase.executeForCallsCount, 0)
    }
  }

  func testExecute_fetchCredentialThrows_deletesIssuanceDPoPKey() async {
    spyFetchCredentialVcSdJwtUseCase.executeForThrowableError = TestingError.error

    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(issuanceDPoPKeyRepository.deleteCallsCount, 1)
      XCTAssertEqual(
        issuanceDPoPKeyRepository.deleteReceivedKeyPair?.identifier,
        issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
    }
  }

  func testExecute_openIdConfigurationWithoutDPoP_doesNotCreateIssuanceDPoPKey() async throws {
    repository.fetchOpenIdConfigurationFromReturnValue = try makeOpenIdConfiguration(dpopSigningAlgValuesSupported: nil)
    repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReturnValue = IssuanceAuthorization(accessToken: mockAccessToken)

    let execution = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundCallsCount, 0)
    XCTAssertEqual(repository.fetchNonceFromCallsCount, 1)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyPair)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopNonce)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyAttestationJWS)
    XCTAssertNil(execution.authorization.dpopKeyPair)
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 0)
  }

  func testExecute_openIdConfigurationWithoutSupportedDPoPAlgorithm_doesNotCreateIssuanceDPoPKey() async throws {
    repository.fetchOpenIdConfigurationFromReturnValue = try makeOpenIdConfiguration(dpopSigningAlgValuesSupported: [JWTAlgorithm.ES384.rawValue])
    repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReturnValue = IssuanceAuthorization(accessToken: mockAccessToken)

    let execution = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundCallsCount, 0)
    XCTAssertEqual(repository.fetchNonceFromCallsCount, 1)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyPair)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopNonce)
    XCTAssertNil(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyAttestationJWS)
    XCTAssertNil(execution.authorization.dpopKeyPair)
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 0)
  }

  func testExecute_openIdConfigurationWithInjectedSupportedDPoPAlgorithm_createsIssuanceDPoPKey() async throws {
    Container.shared.supportedDPoPSigningAlgorithms.register { [.ES256] }
    repository.fetchOpenIdConfigurationFromReturnValue = try makeOpenIdConfiguration(dpopSigningAlgValuesSupported: [JWTAlgorithm.ES256.rawValue])

    let execution = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(repository.fetchNonceFromCallsCount, 2)
    XCTAssertEqual(
      repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReceivedArguments?.dpopKeyPair?.identifier,
      issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
    XCTAssertEqual(execution.authorization.dpopKeyPair?.identifier, issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue?.identifier)
  }

  func testExecute_mixedHolderBindings_createsHardwareBoundIssuanceDPoPKey() async throws {
    let holderBindings = [
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil),
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS"),
    ]

    _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: holderBindings)

    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(issuanceDPoPKeyRepository.createIsHardwareBoundReceivedIsHardwareBound, true)
  }

  func testExecute_missingNonceEndpoint_contextNonceNil() async throws {
    _ = try await useCase(from: mockCredentialOffer, metadataWrapper: CredentialIssuerMetadataWrapper.Mock.sample, holderBindings: mockHolderBindings)

    XCTAssertEqual(repository.fetchNonceFromCallsCount, 0)
    XCTAssertNil(spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext?.nonce)
  }

  // MARK: Private

  private static let mockTokenRequestDPoPNonce = "dpop-nonce-token"
  private static let mockCredentialRequestDPoPNonce = "dpop-nonce-credential"

  private let mockHolderBindings = HolderBinding.Mock.attestedHardwareKey
  private let mockAnyCredential = AnyCredentialSpy()
  private let mockOpenIdConfiguration = OpenIdConfiguration.Mock.sample
  private let mockMetadata = CredentialIssuerMetadata.Mock.sample
  private let mockMetadataWrapper = CredentialIssuerMetadataWrapper.Mock.sampleChasseralIssuer01
  private let mockCredentialOffer = CredentialOffer.Mock.sample
  private let mockAccessToken = AccessToken.Mock.sample
  private let mockNonce = Nonce.Mock.default
  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample
  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockCredentialEncryptionContext = CredentialEncryptionContext(
    issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
    credentialRequestEncryptionAlgorithm: .A128GCM,
    credentialRequestEncryptionZipValue: .deflate,
    responseKeyPair: VaultKeyPair.Mock.ES256,
    credentialResponseEncryptionAlgorithm: .A128GCM,
    credentialResponseEncryptionZipValue: .deflate)

  private var repository = OpenIDRepositoryProtocolSpy()
  private var issuanceDPoPKeyRepository: IssuanceDPoPKeyRepositoryProtocolSpy!
  private var appAttestationRepository: AppAttestationRepositoryProtocolSpy!
  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!
  private var keyAttestationValidator: KeyAttestationValidatorProtocolSpy!
  private var userSession: SessionSpy!
  private var mockContext = LAContextProtocolSpy()

  private let mockVcSdJwtCredential = AnyCredentialSpy()
  private var mockDispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]!
  private var spyFetchCredentialVcSdJwtUseCase: FetchAnyCredentialUseCaseProtocolSpy!
  private var credentialEncryptionContextGeneratorSpy: CredentialEncryptionContextGeneratorProtocolSpy!
  private var nonceResponses: [(nonce: Nonce, dpopNonce: String?)]!

  private var useCase = FetchAnyVerifiableCredentialUseCase()

  private func registerMocks() {
    repository = OpenIDRepositoryProtocolSpy()
    issuanceDPoPKeyRepository = IssuanceDPoPKeyRepositoryProtocolSpy()
    appAttestationRepository = AppAttestationRepositoryProtocolSpy()
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    keyAttestationValidator = KeyAttestationValidatorProtocolSpy()
    userSession = SessionSpy()
    spyFetchCredentialVcSdJwtUseCase = FetchAnyCredentialUseCaseProtocolSpy()
    credentialEncryptionContextGeneratorSpy = CredentialEncryptionContextGeneratorProtocolSpy()
    mockDispatcher = [.vcSdJwt: spyFetchCredentialVcSdJwtUseCase]
    nonceResponses = []

    Container.shared.anyFetchCredentialDispatcher.register { self.mockDispatcher }
    Container.shared.openIDRepository.register { self.repository }
    Container.shared.issuanceDPoPKeyRepository.register { self.issuanceDPoPKeyRepository }
    Container.shared.appAttestationRepository.register { self.appAttestationRepository }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
    Container.shared.userSession.register { self.userSession }
    Container.shared.credentialEncryptionContextGenerator.register { self.credentialEncryptionContextGeneratorSpy }
    Container.shared.supportedDPoPSigningAlgorithms.register { [.ES256] }
    Container.shared.isDPoPEnabled.register { true }
  }

  private func success() {
    spyFetchCredentialVcSdJwtUseCase.executeForReturnValue = .credential(mockAnyCredential)
    credentialEncryptionContextGeneratorSpy.callAsFunctionForReturnValue = mockCredentialEncryptionContext
    repository.fetchOpenIdConfigurationFromReturnValue = mockOpenIdConfiguration
    issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue = VaultKeyPair.Mock.ES256
    repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSReturnValue = IssuanceAuthorization(
      accessToken: mockAccessToken,
      dpopKeyPair: issuanceDPoPKeyRepository.createIsHardwareBoundReturnValue)
    appAttestationRepository.fetchKeyAttestationBodyClientAttestationReturnValue = mockKeyAttestation
    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = true
    userSession.context = mockContext
    nonceResponses = [
      (mockNonce, Self.mockTokenRequestDPoPNonce),
      (mockNonce, Self.mockCredentialRequestDPoPNonce),
    ]
    repository.fetchNonceFromClosure = { _ in self.nonceResponses.removeFirst() }
  }

  private func testCredentialEndpointInvalid(endpoint: String) async throws {
    let metadata = CredentialIssuerMetadata(credentialIssuer: mockMetadata.credentialIssuer, credentialEndpoint: endpoint, credentialConfigurationsSupported: mockMetadata.credentialConfigurationsSupported, display: mockMetadata.display)
    let metadataWrapper = try CredentialIssuerMetadataWrapper(credentialConfigurationId: mockCredentialOffer.credentialConfigurationIds[0], credentialIssuerMetadata: metadata, rawData: Data())
    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: metadataWrapper, holderBindings: [])
      XCTFail("Expected a `FetchAnyVerifiableCredentialError.credentialEndpointCreationError`")
    } catch FetchAnyVerifiableCredentialError.credentialEndpointCreationError {
      XCTAssertEqual(repository.fetchOpenIdConfigurationFromCallsCount, 0)
      XCTAssertEqual(repository.fetchCredentialWithCredentialRequestCallsCount, 0)
      XCTAssertEqual(repository.fetchIssuerPublicKeyInfoFromCallsCount, 0)
      XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeDpopKeyPairDpopNonceDpopKeyAttestationJWSCallsCount, 0)
      XCTAssertEqual(repository.fetchNonceFromCallsCount, 0)
      XCTAssertEqual(spyFetchCredentialVcSdJwtUseCase.executeForCallsCount, 0)
    } catch {
      XCTFail("Expected a `FetchAnyVerifiableCredentialError.credentialEndpointCreationError` but got \(error.localizedDescription)")
    }
  }

  private func makeOpenIdConfiguration(dpopSigningAlgValuesSupported: [String]?) throws -> OpenIdConfiguration {
    var openIdConfigurationObject = try XCTUnwrap(
      JSONSerialization.jsonObject(with: OpenIdConfiguration.Mock.sampleData) as? [String: Any])
    openIdConfigurationObject["dpop_signing_alg_values_supported"] = dpopSigningAlgValuesSupported

    let openIdConfigurationData = try JSONSerialization.data(withJSONObject: openIdConfigurationObject)
    return try JSONDecoder().decode(OpenIdConfiguration.self, from: openIdConfigurationData)
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
