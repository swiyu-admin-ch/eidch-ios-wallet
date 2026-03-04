import Factory
import Spyable
import XCTest
@testable import BITActivity
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
    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)
  }

  func testExecute_validResultDeferredCredential_returns() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReturnValue = FetchAnyCredentialResult.deferred(mockDeferredCrendentialRequest)

    let (credential, _) = try await useCase.execute(from: offer)

    if let deferredCredential = credential as? DeferredCredential {
      XCTAssertEqual(deferredCredential.accessToken, mockDeferredCrendentialRequest.accessToken)
      XCTAssertEqual(deferredCredential.endpoint, mockDeferredCrendentialRequest.endpoint)
      XCTAssertEqual(deferredCredential.transactionId, mockDeferredCrendentialRequest.transactionId)
      XCTAssertEqual(deferredCredential.format, mockDeferredCrendentialRequest.format)

      XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 1)
      XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperCallsCount, 1)
      XCTAssertFalse(trustInformationServiceSpy.fetchForTypeVcSchemaIdCalled)
      XCTAssertFalse(credentialRepository.createVerifiableCredentialCalled)
      XCTAssertFalse(checkAndUpdateCredentialStatusUseCase.executeCalled)
      XCTAssertFalse(activityServiceSpy.createCredentialIdCalled)
    }
  }

  func testExecute_validResultDeferredCredential_argumentsPassed() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReturnValue = FetchAnyCredentialResult.deferred(mockDeferredCrendentialRequest)

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForReceivedOffer, offer)
    XCTAssertEqual(holderBindingContextGenerator.generateFromReceivedMetadataWrapper?.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.metadataWrapper.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.holderBindingContext, mockHolderBindingContext)

    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.deferredCredentialContext, mockDeferredCrendentialRequest)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.metadataWrapper.selectedCredential.claims, metadataWrapper.selectedCredential.claims)
    XCTAssertNotNil(credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperReceivedArguments?.rawOcaBundle)
  }

  func testExecute_validResultCredentialAndTrustStatement_callsCount() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForCallsCount, 1)
    XCTAssertEqual(holderBindingContextGenerator.generateFromCallsCount, 1)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
  }

  func testExecute_validResultCredentialAndTrustStatement_argumentsPassed() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForReceivedOffer, offer)
    XCTAssertEqual(holderBindingContextGenerator.generateFromReceivedMetadataWrapper?.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.metadataWrapper.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReceivedArguments?.holderBindingContext, mockHolderBindingContext)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.anyCredential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.keyBinding, mockCredentialKeyBinding)
    XCTAssertNotNil(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.metadataWrapper.selectedCredential.claims, metadataWrapper.selectedCredential.claims)
    if case .trusted(let statement) = mockTrustInformation.identity {
      XCTAssertEqual(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.trustStatement, statement)
    } else {
      XCTFail("Expected a trusted identity")
    }

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, anyCredential.issuer)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .issuance)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, anyCredential.vcSchemaId)

    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .issuance)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, repositoryCredential.id)
  }

  func testExecute_fetchOCAReturnsNil_passesNilAndReturnsBoth() async throws {
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = nil

    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)

    XCTAssertNil(credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReceivedArguments?.rawOcaBundle)
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
    fetchVcMetadataUseCase.executeAnyCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialGeneratorFailure_throwsError() async throws {
    credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialRepositoryFailure_throwsError() async throws {
    credentialRepository.createVerifiableCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_activityServiceThrows_returnsBoth() async throws {
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)
  }

  func testExecute_checkAndUpdateCredentialStatusFailure_returnsValidCredentialAndTrustStatement() async throws {
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error

    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, repositoryCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)
  }

  // MARK: Private

  private var fetchMetadataUseCase: FetchMetadataUseCaseProtocolSpy!
  private var holderBindingContextGenerator: HolderBindingContextGeneratorProtocolSpy!
  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy!
  private var credentialKeyRepository: CredentialKeyRepositoryProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
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
  private let mockDeferredCrendentialRequest = DeferredCredentialContext.Mock.sample
  private let mockDeferredCrendential = DeferredCredential.Mock.sample
  private var mockCredentialKeyBinding: CredentialKeyBinding!

  private func registerMocks() {
    fetchMetadataUseCase = FetchMetadataUseCaseProtocolSpy()
    holderBindingContextGenerator = HolderBindingContextGeneratorProtocolSpy()
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    trustInformationServiceSpy = TrustInformationServiceProtocolSpy()
    credentialRepository = CredentialRepositoryProcotolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    mockCredentialKeyBinding = try? CredentialKeyBinding(
      id: UUID(uuidString: mockHolderBindingContext.keyPair.identifier)!,
      algorithm: "ES256",
      bindingType: .software,
      publicKey: mockHolderBindingContext.keyPair.publicKey?.toData(),
      privateKey: mockHolderBindingContext.keyPair.privateKey.toData())

    Container.shared.fetchMetadataUseCase.register { self.fetchMetadataUseCase }
    Container.shared.holderBindingContextGenerator.register { self.holderBindingContextGenerator }
    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.trustInformationService.register { self.trustInformationServiceSpy }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.credentialKeyRepository.register { self.credentialKeyRepository }
    Container.shared.activityService.register { self.activityServiceSpy }

  }

  private func success() {
    fetchMetadataUseCase.executeForReturnValue = metadataWrapper
    holderBindingContextGenerator.generateFromReturnValue = mockHolderBindingContext
    fetchAnyVerifiableCredentialUseCase.executeFromMetadataWrapperHolderBindingContextReturnValue = FetchAnyCredentialResult.credential(anyCredential)
    fetchVcMetadataUseCase.executeMetadataReturnValue = rawOcaBundleMock
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    credentialGenerator.generateForKeyBindingRawOcaBundleMetadataWrapperTrustStatementReturnValue = generatedCredential
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
    credentialGenerator.generateDeferredKeyBindingRawOcaBundleMetadataWrapperReturnValue = mockDeferredCrendential
  }
}
