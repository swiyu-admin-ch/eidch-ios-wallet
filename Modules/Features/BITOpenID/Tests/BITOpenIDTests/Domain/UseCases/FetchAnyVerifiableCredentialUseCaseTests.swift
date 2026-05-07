import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCrypto
@testable import BITJWT
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
    XCTAssertEqual(execution.accessToken, mockAccessToken.accessToken)
    XCTAssertEqual(execution.tokenType, .bearer)
    XCTAssertEqual(execution.refreshToken, mockAccessToken.refreshToken)

    XCTAssertTrue(repository.fetchOpenIdConfigurationFromCalled)
    XCTAssertTrue(repository.fetchAccessTokenFromPreAuthorizedCodeCalled)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeReceivedArguments?.url, mockOpenIdConfiguration.tokenEndpoint)
    XCTAssertTrue(repository.fetchNonceFromCalled)
    XCTAssertEqual(repository.fetchNonceFromReceivedUrl, mockMetadataWrapper.credentialIssuerMetadata.nonceEndpoint)

    guard let receivedContext = spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext else {
      XCTFail("receivedContext must not be nil")
      return
    }

    XCTAssertTrue(credentialEncryptionContextGeneratorSpy.callAsFunctionForCalled)
    XCTAssertEqual(receivedContext.format, mockMetadataWrapper.selectedCredential.format)
    XCTAssertEqual(
      receivedContext.selectedCredential as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported,
      mockMetadataWrapper.selectedCredential as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(receivedContext.credentialIssuer, mockMetadataWrapper.credentialIssuerMetadata.credentialIssuer)
    XCTAssertEqual(receivedContext.holderBindings, mockHolderBindings)
    XCTAssertEqual(receivedContext.accessToken, mockAccessToken)
    XCTAssertEqual(receivedContext.nonce, mockNonce)
    XCTAssertEqual(receivedContext.credentialEndpoint.absoluteString, mockMetadataWrapper.credentialIssuerMetadata.credentialEndpoint)
    XCTAssertEqual(receivedContext.credentialEncryptionContext, mockCredentialEncryptionContext)
    XCTAssertEqual(receivedContext.deferredCredentialEndpoint, mockMetadataWrapper.credentialIssuerMetadata.deferredCredentialEndpoint)

    XCTAssertTrue(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
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
      XCTAssertFalse(repository.fetchOpenIdConfigurationFromCalled)
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

  func testExecute_fetchNonceThrows_throws() async {
    repository.fetchNonceFromThrowableError = NetworkError(status: .notFound)

    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)
      XCTFail("An error was expected")
    } catch {
      guard error as? NetworkError != nil else { return XCTFail("Expected a NetworkError") }
      XCTAssertTrue(repository.fetchAccessTokenFromPreAuthorizedCodeCalled)
      XCTAssertFalse(repository.fetchCredentialWithCredentialRequestCalled)
      XCTAssertFalse(repository.fetchIssuerPublicKeyInfoFromCalled)
      XCTAssertFalse(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
    }
  }

  func testExecute_missingNonceEndpoint_contextNonceNil() async throws {
    _ = try await useCase(from: mockCredentialOffer, metadataWrapper: CredentialIssuerMetadataWrapper.Mock.sample, holderBindings: mockHolderBindings)

    XCTAssertFalse(repository.fetchNonceFromCalled)
    XCTAssertNil(spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext?.nonce)
  }

  func testExecute_payloadEncryptionDisabled_doesNotGenerateContext() async throws {
    Container.shared.isPayloadEncryptionEnabled.register { false }
    useCase = FetchAnyVerifiableCredentialUseCase()

    _ = try await useCase(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindings: mockHolderBindings)

    XCTAssertFalse(credentialEncryptionContextGeneratorSpy.callAsFunctionForCalled)
    XCTAssertNil(spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext?.credentialEncryptionContext)
  }

  // MARK: Private

  private let mockHolderBindings = HolderBinding.Mock.attestedHardwareKey
  private let mockAnyCredential = AnyCredentialSpy()
  private let mockOpenIdConfiguration = OpenIdConfiguration.Mock.sample
  private let mockMetadata = CredentialIssuerMetadata.Mock.sample
  private let mockMetadataWrapper = CredentialIssuerMetadataWrapper.Mock.sampleChasseralIssuer01
  private let mockCredentialOffer = CredentialOffer.Mock.sample
  private let mockAccessToken = AccessToken.Mock.sample
  private let mockNonce = Nonce.Mock.default
  private let mockCredentialEncryptionContext = CredentialEncryptionContext(
    issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
    credentialRequestEncryptionAlgorithm: .A128GCM,
    credentialRequestEncryptionZipValue: .deflate,
    responseKeyPair: VaultKeyPair.Mock.ES256,
    credentialResponseEncryptionAlgorithm: .A128GCM,
    credentialResponseEncryptionZipValue: .deflate)

  private var repository = OpenIDRepositoryProtocolSpy()

  private let mockVcSdJwtCredential = AnyCredentialSpy()
  private var mockDispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]!
  private var spyFetchCredentialVcSdJwtUseCase: FetchAnyCredentialUseCaseProtocolSpy!
  private var credentialEncryptionContextGeneratorSpy: CredentialEncryptionContextGeneratorProtocolSpy!

  private var useCase = FetchAnyVerifiableCredentialUseCase()

  private func registerMocks() {
    repository = OpenIDRepositoryProtocolSpy()
    spyFetchCredentialVcSdJwtUseCase = FetchAnyCredentialUseCaseProtocolSpy()
    credentialEncryptionContextGeneratorSpy = CredentialEncryptionContextGeneratorProtocolSpy()
    mockDispatcher = [.vcSdJwt: spyFetchCredentialVcSdJwtUseCase]

    Container.shared.anyFetchCredentialDispatcher.register { self.mockDispatcher }
    Container.shared.openIDRepository.register { self.repository }
    Container.shared.credentialEncryptionContextGenerator.register { self.credentialEncryptionContextGeneratorSpy }
    Container.shared.isPayloadEncryptionEnabled.register { true }
  }

  private func success() {
    spyFetchCredentialVcSdJwtUseCase.executeForReturnValue = .credential(mockAnyCredential)
    credentialEncryptionContextGeneratorSpy.callAsFunctionForReturnValue = mockCredentialEncryptionContext
    repository.fetchOpenIdConfigurationFromReturnValue = mockOpenIdConfiguration
    repository.fetchAccessTokenFromPreAuthorizedCodeReturnValue = mockAccessToken
    repository.fetchNonceFromReturnValue = mockNonce
  }

  private func testCredentialEndpointInvalid(endpoint: String) async throws {
    let metadata = CredentialIssuerMetadata(credentialIssuer: mockMetadata.credentialIssuer, credentialEndpoint: endpoint, credentialConfigurationsSupported: mockMetadata.credentialConfigurationsSupported, display: mockMetadata.display)
    let metadataWrapper = try CredentialIssuerMetadataWrapper(credentialConfigurationId: mockCredentialOffer.credentialConfigurationIds[0], credentialIssuerMetadata: metadata, rawData: Data())
    do {
      _ = try await useCase(from: mockCredentialOffer, metadataWrapper: metadataWrapper, holderBindings: [])
      XCTFail("Expected a `FetchAnyVerifiableCredentialError.credentialEndpointCreationError`")
    } catch FetchAnyVerifiableCredentialError.credentialEndpointCreationError {
      XCTAssertFalse(repository.fetchOpenIdConfigurationFromCalled)
      XCTAssertFalse(repository.fetchCredentialWithCredentialRequestCalled)
      XCTAssertFalse(repository.fetchIssuerPublicKeyInfoFromCalled)
      XCTAssertFalse(repository.fetchAccessTokenFromPreAuthorizedCodeCalled)
      XCTAssertFalse(repository.fetchNonceFromCalled)
      XCTAssertFalse(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
    } catch {
      XCTFail("Expected a `FetchAnyVerifiableCredentialError.credentialEndpointCreationError` but got \(error.localizedDescription)")
    }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
