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

    let result = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindingContext: mockHolderBindingContext)

    if case .credential(let credential) = result {
      XCTAssertEqual(mockAnyCredential.raw, credential.raw)
    }

    XCTAssertTrue(repository.fetchOpenIdConfigurationFromCalled)
    XCTAssertTrue(repository.fetchAccessTokenFromPreAuthorizedCodeCalled)
    XCTAssertEqual(repository.fetchAccessTokenFromPreAuthorizedCodeReceivedArguments?.url, mockOpenIdConfiguration.tokenEndpoint)
    XCTAssertTrue(repository.fetchNonceFromCalled)
    XCTAssertEqual(repository.fetchNonceFromReceivedUrl, mockMetadataWrapper.credentialMetadata.nonceEndpoint)

    guard let receivedContext = spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext else {
      XCTFail("receivedContext must not be nil")
      return
    }

    XCTAssertEqual(receivedContext.format, mockMetadataWrapper.selectedCredential.format)
    XCTAssertEqual(
      receivedContext.selectedCredential as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported,
      mockMetadataWrapper.selectedCredential as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(receivedContext.credentialIssuer, mockMetadataWrapper.credentialMetadata.credentialIssuer)
    XCTAssertEqual(receivedContext.holderBindingContext, mockHolderBindingContext)
    XCTAssertEqual(receivedContext.accessToken, mockAccessToken)
    XCTAssertEqual(receivedContext.nonce, mockNonce)
    XCTAssertEqual(receivedContext.credentialEndpoint.absoluteString, mockMetadataWrapper.credentialMetadata.credentialEndpoint)

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
      _ = try await useCase.execute(from: offer, metadataWrapper: mockMetadataWrapper, holderBindingContext: nil)
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
      _ = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindingContext: nil)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchAccessTokenThrowsInvalidGrant_throws() async {
    repository.fetchAccessTokenFromPreAuthorizedCodeThrowableError = NetworkError(status: .invalidGrant)

    do {
      _ = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindingContext: mockHolderBindingContext)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.expiredInvitation {
      XCTAssertTrue(repository.fetchOpenIdConfigurationFromCalled)
      XCTAssertTrue(repository.fetchAccessTokenFromPreAuthorizedCodeCalled)
      XCTAssertFalse(repository.fetchNonceFromCalled)
      XCTAssertFalse(repository.fetchCredentialWithCredentialRequestCalled)
      XCTAssertFalse(repository.fetchIssuerPublicKeyInfoFromCalled)
      XCTAssertFalse(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
    } catch {
      XCTFail("Not the expected error")
    }
  }

  func testExecute_fetchNonceThrows_throws() async {
    repository.fetchNonceFromThrowableError = NetworkError(status: .notFound)

    do {
      _ = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: mockMetadataWrapper, holderBindingContext: mockHolderBindingContext)
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
    _ = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: CredentialMetadataWrapper.Mock.sample, holderBindingContext: mockHolderBindingContext)

    XCTAssertFalse(repository.fetchNonceFromCalled)
    XCTAssertNil(spyFetchCredentialVcSdJwtUseCase.executeForReceivedContext?.nonce)
  }

  // MARK: Private

  private let mockHolderBindingContext = HolderBindingContext.Mock.attestedHardwareKey
  private let mockAnyCredential = AnyCredentialSpy()
  private let mockOpenIdConfiguration = OpenIdConfiguration.Mock.sample
  private let mockMetadata = CredentialMetadata.Mock.sample
  private let mockMetadataWrapper = CredentialMetadataWrapper.Mock.sampleChasseralIssuer01
  private let mockCredentialOffer = CredentialOffer.Mock.sample
  private let mockAccessToken = AccessToken.Mock.sample
  private let mockNonce = Nonce.Mock.default

  private var repository = OpenIDRepositoryProtocolSpy()

  private let mockVcSdJwtCredential = AnyCredentialSpy()
  private var mockDispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]!
  private var spyFetchCredentialVcSdJwtUseCase: FetchAnyCredentialUseCaseProtocolSpy!

  private var useCase = FetchAnyVerifiableCredentialUseCase()

  private func registerMocks() {
    repository = OpenIDRepositoryProtocolSpy()
    spyFetchCredentialVcSdJwtUseCase = FetchAnyCredentialUseCaseProtocolSpy()
    mockDispatcher = [.vcSdJwt: spyFetchCredentialVcSdJwtUseCase]

    Container.shared.anyFetchCredentialDispatcher.register { self.mockDispatcher }
    Container.shared.openIDRepository.register { self.repository }
  }

  private func success() {
    spyFetchCredentialVcSdJwtUseCase.executeForReturnValue = .credential(mockAnyCredential)
    repository.fetchOpenIdConfigurationFromReturnValue = mockOpenIdConfiguration
    repository.fetchAccessTokenFromPreAuthorizedCodeReturnValue = mockAccessToken
    repository.fetchNonceFromReturnValue = mockNonce
  }

  private func testCredentialEndpointInvalid(endpoint: String) async throws {
    let metadata = CredentialMetadata(credentialIssuer: mockMetadata.credentialIssuer, credentialEndpoint: endpoint, credentialConfigurationsSupported: mockMetadata.credentialConfigurationsSupported, display: mockMetadata.display)
    let metadataWrapper = try CredentialMetadataWrapper(credentialConfigurationId: mockCredentialOffer.credentialConfigurationIds[0], credentialMetadata: metadata, rawData: Data())
    do {
      _ = try await useCase.execute(from: mockCredentialOffer, metadataWrapper: metadataWrapper, holderBindingContext: nil)
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
