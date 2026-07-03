import Factory
import XCTest
@testable import BITActivity
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

// MARK: - RefreshDeferredCredentialUseCaseTests

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

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 1)
    XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount, 1)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(activityService.createCredentialIdCallsCount, 1)
  }

  func testExecute_generateCredentialAssertParameters_success() async throws {
    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForReceivedDeferredCredential, mockDeferredCredential)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, anyCredential)

    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.credential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, mockDeferredCredential.keyBindings.first)
    XCTAssertNotNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.metadataWrapper.rawData, metadataResponse.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.metadataWrapper.credentialConfigurationId, mockDeferredCredential.selectedConfigurationId)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication,
      mockDeferredCredential.authentication)
    if case .trusted(let statement) = mockTrustInformation.identity {
      XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.trustStatement, statement)
    } else {
      XCTFail("Expected a trusted identity")
    }

    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, anyCredential.issuer)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.type, .issuance)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, anyCredential.vcSchemaId)

    XCTAssertEqual(credentialRepository.createVerifiableCredentialReceivedVerifiableCredential?.id, generatedCredential.id)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.id, mockDeferredCredential.id)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.deleteKeyPairs, false)

    XCTAssertEqual(activityService.createCredentialIdReceivedArguments?.activity.type, .issuance)
    XCTAssertEqual(activityService.createCredentialIdReceivedArguments?.credentialId, repositoryCredential.id)

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
  }

  func testExecute_updateDeferredCredential_success() async throws {
    let refreshedAccessToken = AccessToken.Mock.sampleDPoP
    let refreshedAuthentication = CredentialAuthentication(
      accessToken: refreshedAccessToken.accessToken,
      tokenType: refreshedAccessToken.tokenType,
      refreshToken: refreshedAccessToken.refreshToken,
      dpopBinding: mockDeferredCredential.authentication.dpopBinding)
    credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReturnValue = DeferredCredential(
      id: mockDeferredCredential.id,
      transactionId: mockDeferredCredential.transactionId,
      createdAt: mockDeferredCredential.createdAt,
      progressionState: mockDeferredCredential.progressionState,
      endpoint: mockDeferredCredential.endpoint,
      format: mockDeferredCredential.format,
      issuerUrl: mockDeferredCredential.issuerUrl,
      selectedConfigurationId: mockDeferredCredential.selectedConfigurationId,
      issuerDisplays: mockDeferredCredential.issuerDisplays,
      displays: mockDeferredCredential.displays,
      pollingInterval: mockDeferredCredential.pollingInterval,
      keyBindings: mockDeferredCredential.keyBindings,
      rawCredentialData: mockDeferredCredential.rawCredentialData,
      polledAt: mockDeferredCredential.polledAt,
      authentication: refreshedAuthentication)

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataResponse,
      .deferred(
        DeferredCredentialContext(
          transactionId: mockDeferredCredential.transactionId,
          accessToken: refreshedAccessToken,
          endpoint: mockDeferredCredential.endpoint,
          format: mockDeferredCredential.format,
          interval: 1000)))

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.pollingInterval, 1000)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.id, mockDeferredCredential.id)
    XCTAssertNotNil(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.polledAt)
    XCTAssertEqual(
      credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.authentication.accessToken,
      refreshedAccessToken.accessToken)
    XCTAssertEqual(
      credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.authentication.refreshToken,
      refreshedAccessToken.refreshToken)
    XCTAssertEqual(
      credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.authentication.tokenType,
      .dpop)
    XCTAssertEqual(
      credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.authentication.dpopBinding,
      mockDeferredCredential.authentication.dpopBinding)
  }

  func testExecute_updateDeferredCredential_invalid() async throws {
    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataResponse,
      .deferred(
        DeferredCredentialContext(
          transactionId: "invalidTransactionId",
          accessToken: AccessToken.Mock.sample,
          endpoint: mockDeferredCredential.endpoint,
          format: mockDeferredCredential.format,
          interval: 1000)))

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .invalid)
  }

  func testExecute_batchCredential_mapsAndGeneratesCredential_success() async throws {
    let secondCredential: AnyCredential = VcSdJWS.Mock.noKeyBinding
    let firstKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let secondKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let firstKeyBinding = try makeCredentialKeyBinding(from: firstKeyPair)
    let secondKeyBinding = try makeCredentialKeyBinding(from: secondKeyPair)
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = [firstKeyBinding, secondKeyBinding]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataResponse,
      .batch(credentials: [anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsReturnValue = [
      CredentialWithKeyBinding(credential: anyCredential, keyBinding: firstKeyBinding),
      CredentialWithKeyBinding(credential: secondCredential, keyBinding: secondKeyBinding),
    ]

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsCallsCount, 1)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsReceivedArguments?.credentials.count, 2)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsReceivedArguments?.keyBindings.count, 2)
    XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount, 1)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.count,
      2)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.deleteKeyPairs, false)
  }

  func testExecute_batchCredentialWithoutKeyBindings_updatesCredentialIssuanceFailed() async throws {
    fetchDeferredCredentialService.callAsFunctionForReturnValue = (metadataResponse, .batch(credentials: [anyCredential]))

    try await useCase.execute(for: mockDeferredCredential)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_batchCredential_mapCredentialsToKeyBindingsThrows_updatesCredentialIssuanceFailed() async throws {
    let secondCredential: AnyCredential = VcSdJWS.Mock.noKeyBinding
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = try [makeCredentialKeyBinding(from: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()))]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataResponse,
      .batch(credentials: [anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsThrowableError = TestingError.error

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_batchCredential_mapCredentialsToKeyBindingsReturnsEmpty_updatesCredentialIssuanceFailed() async throws {
    let secondCredential: AnyCredential = VcSdJWS.Mock.noKeyBinding
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = try [makeCredentialKeyBinding(from: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()))]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataResponse,
      .batch(credentials: [anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.executeCredentialsKeyBindingsReturnValue = []

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_cannotRefreshCredential_success() async throws {
    try await useCase.execute(for: .Mock.sampleIncorrectInterval)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdCallsCount, 0)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 0)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 0)
  }

  func testExecute_deferredCredentialIsInvalid_doesNotRefresh() async throws {
    try await useCase.execute(for: .Mock.sampleInvalid)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdCallsCount, 0)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 0)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 0)
  }

  func testExecute_deferredCredentialHasNoSeclectedConfigurationId_throws() async throws {
    do {
      try await useCase.execute(for: .Mock.sampleWithoutSelectedConfigurationId)
    } catch {
      XCTAssertEqual(error as? RefreshDeferredCredentialUseCaseError, .invalidConfigurationId)
      XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 1)
    }
  }

  func testExecute_metadataWrapperCreationFails_throws() async throws {
    let invalidMetadata = CredentialIssuerMetadata(
      credentialIssuer: "https://issuer",
      credentialEndpoint: "https://endpoint",
      credentialConfigurationsSupported: [:],
      display: nil)
    let invalidResponse = CredentialIssuerMetadataResponse(metadata: invalidMetadata, raw: Data())

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (invalidResponse, .credential(anyCredential))

    do {
      try await useCase.execute(for: mockDeferredCredential)
    } catch {
      XCTAssertEqual(error as? RefreshDeferredCredentialUseCaseError, .invalidCredentialIssuerMetadata)
    }
  }

  func testExecute_fetchDeferredCredentialServiceThrowsInvalidCredential_throws() async throws {
    fetchDeferredCredentialService.callAsFunctionForThrowableError = OpenIdRepositoryError.invalidCredential

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .invalid)
  }

  func testExecute_fetchDeferredCredentialServiceThrowsAnyException_setStateToIssuanceFailed() async throws {
    fetchDeferredCredentialService.callAsFunctionForThrowableError = TestingError.error

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_checkAndUpdateCredentialStatusFailure() async throws {
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error

    do {
      try await useCase.execute(for: mockDeferredCredential)
      XCTAssertTrue(true)
    } catch {
      XCTFail("Expected no exception")
    }
  }

  // MARK: Private

  private var useCase: RefreshDeferredCredentialUseCase!

  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private var fetchDeferredCredentialService: FetchDeferredCredentialServiceProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var trustInformationService: TrustInformationServiceProtocolSpy!
  private var activityService: ActivityServiceProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<VcSdJwt>!

  private let mockDeferredCredential = DeferredCredential.Mock.sample
  private let updatedDeferredCredential = DeferredCredential(
    transactionId: "transactionId",
    endpoint: "endpoint",
    format: "format",
    issuerUrl: "https://issuer",
    authentication: CredentialAuthentication(accessToken: "accessToken"))

  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let anyCredential = VcSdJWS.Mock.sample
  private let metadataResponse = CredentialIssuerMetadataResponse(metadata: CredentialIssuerMetadata.Mock.sample, raw: CredentialIssuerMetadata.Mock.sampleData)
  private let updatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty

  private func registerMocks() {
    fetchDeferredCredentialService = FetchDeferredCredentialServiceProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    trustInformationService = TrustInformationServiceProtocolSpy()
    credentialRepository = CredentialRepositoryProcotolSpy()
    activityService = ActivityServiceProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()

    Container.shared.fetchDeferredCredentialService.register { self.fetchDeferredCredentialService }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.trustInformationService.register { self.trustInformationService }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.activityService.register { self.activityService }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { self.mapCredentialsToKeyBindingsUseCase }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
  }

  private func createSuccessState() {
    fetchDeferredCredentialService.callAsFunctionForReturnValue = (metadataResponse, .credential(anyCredential))
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    fetchVcMetadataUseCase.executeMetadataReturnValue = rawOcaBundleMock
    credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReturnValue = generatedCredential
    credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReturnValue = mockDeferredCredential
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    credentialRepository.updateDeferredCredentialReturnValue = updatedDeferredCredential
    trustInformationService.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
  }

  private func makeCredentialKeyBinding(from keyPair: VaultKeyPair) throws -> KeyBinding {
    try KeyBinding(
      id: UUID(uuidString: keyPair.identifier) ?? UUID(),
      algorithm: keyPair.algorithm.rawValue,
      bindingType: .software,
      publicKey: keyPair.publicKey?.toData(),
      privateKey: keyPair.privateKey.toData())
  }

}
