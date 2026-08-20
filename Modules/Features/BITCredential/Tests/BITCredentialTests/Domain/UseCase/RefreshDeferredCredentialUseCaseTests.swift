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
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsCallsCount, 1)
    XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
  }

  func testExecute_generateCredentialAssertParameters_success() async throws {
    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForReceivedDeferredCredential, mockDeferredCredential)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, anyCredential)

    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.credential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, keyBindingMock)
    XCTAssertNotNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.metadataWrapper.metadataJws, metadataJwsMock)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.metadataWrapper.credentialConfigurationId, mockDeferredCredential.selectedConfigurationId)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication,
      mockDeferredCredential.authentication)

    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid, anyCredential.issuer)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.metadataJws, metadataJwsMock)

    XCTAssertEqual(credentialRepository.createVerifiableCredentialReceivedVerifiableCredential?.id, generatedCredential.id)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.id, mockDeferredCredential.id)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.deleteKeyPairs, false)

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
      metadataJwsMock,
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
      metadataJwsMock,
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
    let secondKeyBinding = KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = [keyBindingMock, secondKeyBinding]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataJwsMock,
      .credential([anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsReturnValue = [
      CredentialWithKeyBinding(credential: anyCredential, keyBinding: keyBindingMock),
      CredentialWithKeyBinding(credential: secondCredential, keyBinding: secondKeyBinding),
    ]

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsCallsCount, 1)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsReceivedArguments?.credentials.count, 2)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsReceivedArguments?.keyBindings.count, 2)
    XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid, anyCredential.issuer)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount, 1)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.count,
      2)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 1)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.deleteKeyPairs, false)
  }

  func testExecute_credentialWithoutKeyBindings_updatesCredentialIssuanceFailed() async throws {
    fetchDeferredCredentialService.callAsFunctionForReturnValue = (metadataJwsMock, .credential([anyCredential]))

    try await useCase.execute(for: DeferredCredential.Mock.sampleWithoutKeyBindings)
    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_batchCredential_mapCredentialsToKeyBindingsThrows_updatesCredentialIssuanceFailed() async throws {
    let secondCredential: AnyCredential = VcSdJWS.Mock.noKeyBinding
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = [keyBindingMock]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataJwsMock,
      .credential([anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsThrowableError = TestingError.error

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_batchCredential_mapCredentialsToKeyBindingsReturnsEmpty_updatesCredentialIssuanceFailed() async throws {
    let secondCredential: AnyCredential = VcSdJWS.Mock.noKeyBinding
    var deferredCredential = mockDeferredCredential
    deferredCredential.keyBindings = [keyBindingMock]

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (
      metadataJwsMock,
      .credential([anyCredential, secondCredential]))
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsReturnValue = []

    try await useCase.execute(for: deferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_cannotRefreshCredential_success() async throws {
    try await useCase.execute(for: .Mock.sampleIncorrectInterval)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 0)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 0)
  }

  func testExecute_deferredCredentialIsInvalid_doesNotRefresh() async throws {
    try await useCase.execute(for: .Mock.sampleInvalid)

    XCTAssertEqual(fetchDeferredCredentialService.callAsFunctionForCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 0)
    XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 0)
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
    let invalidMetadata = try CredentialIssuerMetadata(
      credentialIssuer: Self.issuerUrl,
      credentialEndpoint: "https://endpoint",
      credentialConfigurationsSupported: [:],
      display: nil,
      credentialRequestEncryption: .Mock.sample,
      credentialResponseEncryption: .Mock.sample,
      nonceEndpoint: XCTUnwrap(URL(string: "https://example.com/nonce")))
    let invalidMetadataJws = CredentialIssuerMetadataJWT.Mock.createJWS(from: invalidMetadata)

    fetchDeferredCredentialService.callAsFunctionForReturnValue = (invalidMetadataJws, .credential([anyCredential]))

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

  func testExecute_credentialDidNotSameAsMetadata_issuanceFailed() async throws {
    actorIdentityValidator.validateIssuerDidMetadataJwsThrowableError = GovernanceError.unverifiedActor

    try await useCase.execute(for: mockDeferredCredential)

    XCTAssertEqual(credentialRepository.updateDeferredCredentialReceivedDeferredCredential?.progressionState, .issuanceFailed)
  }

  func testExecute_protectedIssuanceValidatorThrows_issuanceFailed() async throws {
    protectedIssuanceValidator.validateAnyCredentialMetadataWrapperThrowableError = TestingError.error

    try await useCase.execute(for: mockDeferredCredential)

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

  private static let issuerUrl = URL(string: "https://issuer.domain.ch")!

  private var useCase: RefreshDeferredCredentialUseCase!

  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var fetchDeferredCredentialService: FetchDeferredCredentialServiceProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<VcSdJwt>!
  private var protectedIssuanceValidator: ProtectedIssuanceValidatorProtocolSpy!
  private var actorIdentityValidator: ActorIdentityValidatorProtocolSpy!

  private let mockDeferredCredential = DeferredCredential.Mock.sample
  private let updatedDeferredCredential = DeferredCredential(
    transactionId: "transactionId",
    endpoint: "endpoint",
    format: .vcSdJwt,
    issuerUrl: issuerUrl,
    authentication: CredentialAuthentication(accessToken: "accessToken"))
  private let keyBindingMock = KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)

  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let anyCredential = VcSdJWS.Mock.sample
  private let metadataJwsMock = CredentialIssuerMetadataJWT.Mock.sample
  private let updatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty

  private func registerMocks() {
    fetchDeferredCredentialService = FetchDeferredCredentialServiceProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    credentialRepository = CredentialRepositoryProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    protectedIssuanceValidator = ProtectedIssuanceValidatorProtocolSpy()
    actorIdentityValidator = ActorIdentityValidatorProtocolSpy()

    Container.shared.fetchDeferredCredentialService.register { self.fetchDeferredCredentialService }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { self.mapCredentialsToKeyBindingsUseCase }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.protectedIssuanceValidator.register { self.protectedIssuanceValidator }
    Container.shared.actorIdentityValidator.register { self.actorIdentityValidator }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:example:123$/# }
  }

  private func createSuccessState() {
    fetchDeferredCredentialService.callAsFunctionForReturnValue = (metadataJwsMock, .credential([anyCredential]))
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    fetchVcMetadataUseCase.executeMetadataReturnValue = rawOcaBundleMock
    credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReturnValue = generatedCredential
    credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReturnValue = mockDeferredCredential
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyBindingsReturnValue = [CredentialWithKeyBinding(credential: anyCredential, keyBinding: keyBindingMock)]
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    credentialRepository.updateDeferredCredentialReturnValue = updatedDeferredCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
  }
}
