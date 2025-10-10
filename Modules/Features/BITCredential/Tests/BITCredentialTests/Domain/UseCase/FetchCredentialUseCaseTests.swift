import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class FetchCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    useCase = FetchCredentialUseCase()

    success()
  }

  func testExecute_validResultCredentialAndTrustStatement_returnsBoth() async throws {
    let result = try await useCase.execute(from: offer)

    if case .credential(let credential, let trustInformation) = result {
      XCTAssertEqual(credential, updatedCredential)
      XCTAssertEqual(trustInformation, mockTrustInformation)
    }
  }

  func testExecute_validResultDeferredCredential_returns() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReturnValue = FetchAnyCredentialResult.deferred(transactionId: mockTransactionId, accessToken: mockAccessToken, endpoint: mockDeferredCredentialEndpoint, format: mockFormat)

    let result = try await useCase.execute(from: offer)

    if case .deferred(let deferredCredential) = result {
      XCTAssertEqual(deferredCredential.accessToken, mockAccessToken)
      XCTAssertEqual(deferredCredential.endpoint, mockDeferredCredentialEndpoint)
      XCTAssertEqual(deferredCredential.transactionId, mockTransactionId)
      XCTAssertEqual(deferredCredential.format, mockFormat)

      XCTAssertFalse(fetchVcMetadataUseCase.executeForCalled)
      XCTAssertFalse(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperCalled)
      XCTAssertFalse(trustInformationServiceSpy.fetchForTypeVcSchemaIdCalled)
      XCTAssertFalse(verifiableCredentialRepository.createCalled)
      XCTAssertFalse(checkAndUpdateCredentialStatusUseCase.executeCalled)
    }
  }

  func testExecute_validResultCredentialAndTrustStatement_callsCount() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForCallsCount, 1)
    XCTAssertEqual(holderBindingContextGenerator.generateFromCallsCount, 1)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeForCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperCallsCount, 1)
    XCTAssertEqual(verifiableCredentialRepository.createCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
  }

  func testExecute_validResultCredentialAndTrustStatement_argumentsPassed() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForReceivedOffer, offer)
    XCTAssertEqual(holderBindingContextGenerator.generateFromReceivedMetadataWrapper?.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.metadataWrapper.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.holderBindingContext, mockHolderBindingContext)
    XCTAssertEqual(fetchVcMetadataUseCase.executeForReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReceivedArguments?.anyCredential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReceivedArguments?.keyPair, mockHolderBindingContext.keyPair)
    XCTAssertNotNil(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReceivedArguments?.metadataWrapper.selectedCredential.claims, metadataWrapper.selectedCredential.claims)

    for issuerDisplay in verifiableCredentialRepository.createReceivedCredential!.issuerDisplays {
      XCTAssertEqual(issuerDisplay.name, "\(issuerDisplay.locale!) entityName")
    }
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, anyCredential.issuer)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .issuance)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, anyCredential.vcSchemaId)
  }

  func testExecute_fetchOCAReturnsNil_passesNilAndReturnsBoth() async throws {
    fetchVcMetadataUseCase.executeForReturnValue = nil

    let result = try await useCase.execute(from: offer)

    if case .credential(let credential, let trustInformation) = result {
      XCTAssertEqual(credential, updatedCredential)
      XCTAssertEqual(trustInformation, mockTrustInformation)
    }

    for issuerDisplay in verifiableCredentialRepository.createReceivedCredential!.issuerDisplays {
      XCTAssertEqual(issuerDisplay.name, "\(issuerDisplay.locale!) entityName")
    }
    XCTAssertNil(credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
  }

  func testExecute_fetchMetadataUseCase_throwsError() async throws {
    fetchMetadataUseCase.executeForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_holderBindingContextGenerator_throwsError() async throws {
    holderBindingContextGenerator.generateFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchAnyVerifiableCredential_throwsErrorAndDeletesKey() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(credentialKeyRepository.deleteCalled)
    }
  }

  func testExecute_fetchVcMetadataFailure_throwsError() async throws {
    useCase = FetchCredentialUseCase()
    fetchVcMetadataUseCase.executeForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialGeneratorFailure_throwsError() async throws {
    credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_verifiableCredentialRepositoryFailure_throwsError() async throws {
    verifiableCredentialRepository.createThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_checkAndUpdateCredentialStatusFailure_returnsValidCredentialAndTrustStatement() async throws {
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error

    let result = try await useCase.execute(from: offer)

    if case .credential(let credential, let trustInformation) = result {
      XCTAssertEqual(credential, repositoryCredential)
      XCTAssertEqual(trustInformation, mockTrustInformation)
    }
  }

  // MARK: Private

  private var fetchMetadataUseCase: FetchMetadataUseCaseProtocolSpy!
  private var holderBindingContextGenerator: HolderBindingContextGeneratorProtocolSpy!
  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var verifiableCredentialRepository: VerifiableCredentialRepositoryProcotolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy!
  private var credentialKeyRepository: CredentialKeyRepositoryProtocolSpy!
  private var useCase: FetchCredentialUseCase!

  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let updatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty
  private let metadataWrapper: CredentialMetadataWrapper = .Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let offer: CredentialOffer = .Mock.sample
  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let mockHolderBindingContext = HolderBindingContext.Mock.softwareKey
  private let mockAccessToken = "mock_access_token"
  private let mockDeferredCredentialEndpoint = "mock_deferred_credential_endpoint"
  private let mockTransactionId = "mock_transaction_id"
  private let mockFormat = "mock_format"

  private func registerMocks() {
    fetchMetadataUseCase = FetchMetadataUseCaseProtocolSpy()
    holderBindingContextGenerator = HolderBindingContextGeneratorProtocolSpy()
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    trustInformationServiceSpy = TrustInformationServiceProtocolSpy()
    verifiableCredentialRepository = VerifiableCredentialRepositoryProcotolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()

    Container.shared.fetchMetadataUseCase.register { self.fetchMetadataUseCase }
    Container.shared.holderBindingContextGenerator.register { self.holderBindingContextGenerator }
    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.trustInformationService.register { self.trustInformationServiceSpy }
    Container.shared.verifiableCredentialRepository.register { self.verifiableCredentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.credentialKeyRepository.register { self.credentialKeyRepository }

  }

  private func success() {
    fetchMetadataUseCase.executeForReturnValue = metadataWrapper
    holderBindingContextGenerator.generateFromReturnValue = mockHolderBindingContext
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReturnValue = FetchAnyCredentialResult.credential(anyCredential)
    fetchVcMetadataUseCase.executeForReturnValue = rawOcaBundleMock
    credentialGenerator.generateForKeyPairRawOcaBundleMetadataWrapperReturnValue = generatedCredential
    verifiableCredentialRepository.createReturnValue = repositoryCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_cast
