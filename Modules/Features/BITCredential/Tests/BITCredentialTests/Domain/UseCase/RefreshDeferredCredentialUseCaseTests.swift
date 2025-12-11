import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class RefreshDeferredCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    registerMocks()
    useCase = RefreshDeferredCredentialUseCase()
    createSuccessState()
  }

  func testExecute_generateCredentialAssertCount_success() async throws {
    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperCallsCount, 1)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteCallsCount, 1)
  }

  func testExecute_generateCredentialAssertParameters_success() async throws {
    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatReceivedArguments?.transactionId, mockDeferredCredential.transactionId)
    XCTAssertEqual(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatReceivedArguments?.acccessToken, mockDeferredCredential.accessToken)
    XCTAssertEqual(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatReceivedArguments?.format, mockDeferredCredential.format)
    XCTAssertEqual(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatReceivedArguments?.url.absoluteString, mockDeferredCredential.endpoint)

    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.anyCredential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.keyBinding, mockDeferredCredential.keyBinding)
    XCTAssertNotNil(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.metadataWrapper.rawData, mockDeferredCredential.rawCredentialData?.rawOIDMetadata)

    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, anyCredential.issuer)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.type, .issuance)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, anyCredential.vcSchemaId)

    XCTAssertEqual(credentialRepository.createVerifiableCredentialReceivedVerifiableCredential?.id, generatedCredential.id)
    XCTAssertEqual(credentialRepository.deleteReceivedId, mockDeferredCredential.id)
  }

  func testExecute_updateDeferredCredentialAssertCount_success() async throws {
    openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatThrowableError = OpenIdRepositoryError.credentialIssuancePending(interval: 1000)

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.pollingInterval, 1000)
  }

  func testExecute_updateDeferredCredentialAssertParameters_success() async throws {
    openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatThrowableError = OpenIdRepositoryError.credentialIssuancePending(interval: 1000)

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.id, mockDeferredCredential.id)
  }

  func testExecute_cannotRefreshCredential_success() async throws {
    try await useCase.execute(for: .Mock.sampleIncorrectInterval)

    XCTAssertFalse(openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatCalled)
    XCTAssertFalse(fetchVcMetadataUseCase.executeAnyCredentialCalled)
    XCTAssertFalse(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperCalled)
    XCTAssertFalse(trustInformationService.fetchForTypeVcSchemaIdCalled)
    XCTAssertFalse(credentialRepository.createVerifiableCredentialCalled)
    XCTAssertFalse(credentialRepository.deleteCalled)
  }

  func testExecute_deferredCredentialWithInvalidEndpoint_throws() async throws {
    do {
      try await useCase.execute(for: .Mock.sampleWithoutValidEndpoint)
    } catch {
      XCTAssertEqual(error as? RefreshDeferredCredentialUseCaseError, .invalidCredentialUrl)
    }
  }

  func testExecute_deferredCredentialHasNoSeclectedConfigurationId_throws() async throws {
    do {
      try await useCase.execute(for: .Mock.sampleWithoutSelectedConfigurationId)
    } catch {
      XCTAssertEqual(error as? RefreshDeferredCredentialUseCaseError, .invalidCredentialMetadata)
    }
  }

  func testExecute_deferredCredentialHasNoMetadata_throws() async throws {
    do {
      try await useCase.execute(for: .Mock.sampleWithoutMetadata)
    } catch {
      XCTAssertEqual(error as? RefreshDeferredCredentialUseCaseError, .invalidCredentialMetadata)
    }
  }

  func testExecute_refreshDeferredCredentialFails_throws() async throws {
    openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchVcMetadataFailure_throwsError() async throws {
    fetchVcMetadataUseCase.executeAnyCredentialThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialGeneratorFailure_throwsError() async throws {
    credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_createVerifiableCredentialRepositoryFailure_throwsError() async throws {
    credentialRepository.createVerifiableCredentialThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_deleteDeferredCredentialRepositoryFailure_throwsError() async throws {
    credentialRepository.deleteThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: RefreshDeferredCredentialUseCase!

  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private var openIDRepository: OpenIDRepositoryProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var trustInformationService: TrustInformationServiceProtocolSpy!

  private let mockDeferredCredential = DeferredCredential.Mock.sample
  private let updatedDeferredCredential = DeferredCredential(
    transactionId: "transactionId",
    accessToken: "accessToken",
    endpoint: "endpoint",
    format: "format")

  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let metadataWrapper: CredentialMetadataWrapper = .Mock.sample
  private let keyPairRawRepresentationMock = ("publicKeyData".data(using: .utf8)!, "privateKeyData".data(using: .utf8)!)

  private func registerMocks() {
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    trustInformationService = TrustInformationServiceProtocolSpy()
    credentialRepository = CredentialRepositoryProcotolSpy()
    openIDRepository = OpenIDRepositoryProtocolSpy()

    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.trustInformationService.register { self.trustInformationService }
    Container.shared.openIDRepository.register { self.openIDRepository }
    Container.shared.credentialRepository.register { self.credentialRepository }
  }

  private func createSuccessState() {
    openIDRepository.refreshDeferredCredentialFromTransactionIdAcccessTokenFormatReturnValue = anyCredential
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperReturnValue = generatedCredential
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    credentialRepository.updateDeferredCredentialReturnValue = updatedDeferredCredential
    trustInformationService.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
  }

}
