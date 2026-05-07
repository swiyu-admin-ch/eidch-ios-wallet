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
@testable import BITVault

// MARK: - FetchCredentialUseCaseTests

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
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCrendentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    let (credential, _) = try await useCase.execute(from: offer)

    if let deferredCredential = credential as? DeferredCredential {
      XCTAssertEqual(deferredCredential.authentication.accessToken, mockDeferredCrendentialRequest.accessToken)
      XCTAssertEqual(deferredCredential.endpoint, mockDeferredCrendentialRequest.endpoint)
      XCTAssertEqual(deferredCredential.transactionId, mockDeferredCrendentialRequest.transactionId)
      XCTAssertEqual(deferredCredential.format, mockDeferredCrendentialRequest.format)

      XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 1)
      XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperCallsCount, 1)
      XCTAssertFalse(trustInformationServiceSpy.fetchForTypeVcSchemaIdCalled)
      XCTAssertFalse(credentialRepository.createVerifiableCredentialCalled)
      XCTAssertFalse(checkAndUpdateCredentialStatusUseCase.executeCalled)
      XCTAssertFalse(activityServiceSpy.createCredentialIdCalled)
    }
  }

  func testExecute_validResultDeferredCredential_argumentsPassed() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCrendentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForReceivedOffer, offer)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionFromReceivedMetadataWrapper?.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.metadataWrapper.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.holderBindings, mockHolderBindings)

    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReceivedArguments?.deferredCredentialContext, mockDeferredCrendentialRequest)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReceivedArguments?.keyBindings, [mockCredentialKeyBinding])
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReceivedArguments?.metadataWrapper.selectedCredential.credentialMetadata?.claims, metadataWrapper.selectedCredential.credentialMetadata?.claims)
    XCTAssertNotNil(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReceivedArguments?.rawOcaBundle)
  }

  func testExecute_validResultDeferredCredential_passesAllKeyBindingsToGenerator() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCrendentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    holderBindingsGenerator.callAsFunctionFromReturnValue = HolderBinding.Mock.batch

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      Set(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReceivedArguments?.keyBindings.map(\.id.uuidString) ?? []),
      Set(HolderBinding.Mock.batch.map(\.keyPair.identifier)))
  }

  func testExecute_validResultCredentialAndTrustStatement_callsCount() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForCallsCount, 1)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionFromCallsCount, 1)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
  }

  func testExecute_validResultCredentialAndTrustStatement_argumentsPassed() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchMetadataUseCase.executeForReceivedOffer, offer)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionFromReceivedMetadataWrapper?.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.metadataWrapper.rawData, metadataWrapper.rawData)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.holderBindings, mockHolderBindings)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.credential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, mockCredentialKeyBinding)
    XCTAssertNotNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.metadataWrapper.selectedCredential.credentialMetadata?.claims,
      metadataWrapper.selectedCredential.credentialMetadata?.claims)
    if case .trusted(let statement) = mockTrustInformation.identity {
      XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.trustStatement, statement)
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

  func testExecute_validResultCredentialAndTrustStatement_passesRefreshTokenToCredentialGenerator() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential(anyCredential),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: "refresh-token")

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication.refreshToken,
      "refresh-token")
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication.accessToken,
      mockAccessToken)
  }

  func testExecute_fetchOCAReturnsNil_passesNilAndReturnsBoth() async throws {
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = nil

    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)

    XCTAssertNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.rawOcaBundle)
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

  func testExecute_holderBindingsGenerator_throwsError() async throws {
    holderBindingsGenerator.callAsFunctionFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_holderBindingsGeneratorThrows_propagatesError() async throws {
    holderBindingsGenerator.callAsFunctionFromThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(from: offer)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertFalse(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsCalled)
    }
  }

  func testExecute_fetchAnyVerifiableCredential_throwsErrorAndDeletesKey() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(credentialKeyRepository.deleteCalled)
    }
  }

  func testExecute_batchResultWithoutBatchMetadata_throwsInvalidCredentialAndDeletesKey() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .batch(credentials: [anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a FetchCredentialUseCaseError.invalidCredential instead")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
      XCTAssertTrue(credentialKeyRepository.deleteCalled)
    }
  }

  func testExecute_validBatchResult_returnsBothAndMapsCredentialsToKeyBindings() async throws {
    let metadataWithBatchSize = CredentialIssuerMetadataWrapper.Mock.sampleBatch
    let mappedCredential = CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)

    fetchMetadataUseCase.executeForReturnValue = metadataWithBatchSize
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .batch(credentials: [anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsReturnValue = [mappedCredential]

    let (credential, trustInformation) = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(trustInformation, mockTrustInformation)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsCallsCount, 1)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsReceivedArguments?.credentials.first?.raw, anyCredential.raw)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsReceivedArguments?.keyPairs.first?.identifier, mockHolderBindings.first?.keyPair.identifier)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication,
      CredentialAuthentication(accessToken: mockAccessToken))
  }

  func testExecute_validBatchResult_passesRefreshTokenToCredentialGenerator() async throws {
    let metadataWithBatchSize = CredentialIssuerMetadataWrapper.Mock.sampleBatch
    let mappedCredential = CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)

    fetchMetadataUseCase.executeForReturnValue = metadataWithBatchSize
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .batch(credentials: [anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: "refresh-token")
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsReturnValue = [mappedCredential]

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication.refreshToken,
      "refresh-token")
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication.accessToken,
      mockAccessToken)
  }

  func testExecute_batchResultWithNoMappedCredential_throwsInvalidCredentialAndDeletesKey() async throws {
    fetchMetadataUseCase.executeForReturnValue = CredentialIssuerMetadataWrapper.Mock.sampleBatch
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .batch(credentials: [anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyPairsReturnValue = []

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a FetchCredentialUseCaseError.invalidCredential instead")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
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
    credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationThrowableError = TestingError.error

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
  private var holderBindingsGenerator: HolderBindingsGeneratorProtocolSpy!
  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy!
  private var credentialKeyRepository: CredentialKeyRepositoryProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var useCase: FetchCredentialUseCase!

  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let updatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty
  private let metadataWrapper: CredentialIssuerMetadataWrapper = .Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let offer: CredentialOffer = .Mock.sample
  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let mockAccessToken = "access-token"
  private let mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let mockHolderBindings = HolderBinding.Mock.softwareKey
  private let mockDeferredCrendentialRequest = DeferredCredentialContext.Mock.sample
  private let mockDeferredCrendential = DeferredCredential.Mock.sample
  private var mockCredentialKeyBinding: KeyBinding!

  private func registerMocks() {
    fetchMetadataUseCase = FetchMetadataUseCaseProtocolSpy()
    holderBindingsGenerator = HolderBindingsGeneratorProtocolSpy()
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    trustInformationServiceSpy = TrustInformationServiceProtocolSpy()
    credentialRepository = CredentialRepositoryProcotolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    mockCredentialKeyBinding = try? KeyBinding(
      id: UUID(uuidString: mockHolderBindings.first!.keyPair.identifier)!,
      algorithm: "ES256",
      bindingType: .software,
      publicKey: mockHolderBindings.first?.keyPair.publicKey?.toData(),
      privateKey: mockHolderBindings.first?.keyPair.privateKey.toData())

    Container.shared.fetchMetadataUseCase.register { self.fetchMetadataUseCase }
    Container.shared.holderBindingsGenerator.register { self.holderBindingsGenerator }
    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.trustInformationService.register { self.trustInformationServiceSpy }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.credentialKeyRepository.register { self.credentialKeyRepository }
    Container.shared.activityService.register { self.activityServiceSpy }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { self.mapCredentialsToKeyBindingsUseCase }

  }

  private func success() {
    fetchMetadataUseCase.executeForReturnValue = metadataWrapper
    holderBindingsGenerator.callAsFunctionFromReturnValue = mockHolderBindings
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential(anyCredential),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: nil)
    fetchVcMetadataUseCase.executeMetadataReturnValue = rawOcaBundleMock
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReturnValue = generatedCredential
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
    credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperReturnValue = mockDeferredCrendential
  }
}
