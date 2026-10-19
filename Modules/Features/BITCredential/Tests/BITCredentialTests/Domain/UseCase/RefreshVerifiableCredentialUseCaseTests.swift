import Factory
import Foundation
import Testing
@testable import BITAnalytics
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try force_cast

@Suite
struct RefreshVerifiableCredentialUseCaseTests: @unchecked Sendable {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    registerMocks()
    createSuccessState()
    useCase = RefreshVerifiableCredentialUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success_refreshesAndUpdatesCredential() async throws {
    let refreshedCredential = try await useCase(credential)

    #expect(openIDRepository.fetchMetadataFromCallsCount == 1)
    #expect(openIDRepository.fetchMetadataFromReceivedIssuerUrl == credential.issuerUrl)

    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationCallsCount == 1)
    #expect(
      refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.metadataWrapper.credentialConfigurationId ==
        credential.selectedConfigurationId)
    #expect(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCallsCount == 1)
    #expect(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.batchSize == Self.metadataJwsMock.payload.credentialIssuerMetadata.batchCredentialIssuance?.batchSize)
    #expect(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.proofTypes == Self.metadataJwsMock.payload.credentialIssuerMetadata.credentialConfigurationsSupported.first?.value.proofTypesSupported)
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.holderBindings?.count == 1)
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.holderBindings == holderBindings)
    #expect(keyBindingGenerator.generateFromCallsCount == 1)
    let expectedAuthorization = IssuanceAuthorization(
      accessToken: AccessToken(
        accessToken: credential.authentication.accessToken,
        tokenType: credential.authentication.tokenType,
        refreshToken: credential.authentication.refreshToken))
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.authorization == expectedAuthorization)

    #expect(actorIdentityValidator.validateCallsCount == 1)
    #expect(actorIdentityValidator.validateReceivedMetadataJws == Self.metadataJwsMock)
    #expect(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount == 1)
    #expect(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid == anyCredential.issuer)
    #expect(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.metadataJws == Self.metadataJwsMock)

    #expect(fetchVcMetadataUseCase.executeAnyCredentialCallsCount == 1)
    #expect(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw == anyCredential.raw)

    #expect(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount == 1)
    #expect(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding ==
        Self.refreshedKeyBinding)
    let expectedAuthentication = CredentialAuthentication(
      accessToken: refreshedAccessToken.accessToken,
      tokenType: refreshedAccessToken.tokenType,
      refreshToken: refreshedAccessToken.refreshToken,
      dpopBinding: dpopKeyBinding)
    #expect(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication == expectedAuthentication)

    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 1)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.id == credential.id)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.createdAt == credential.createdAt)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.refreshedAt != nil)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.authentication.accessToken == refreshedAccessToken.accessToken)

    #expect(checkAndUpdateCredentialStatusUseCase.callAsFunctionForCallsCount == 1)
    #expect(checkAndUpdateCredentialStatusUseCase.callAsFunctionForReceivedCredential == savedCredential)
    #expect(refreshedCredential == checkedCredential)
  }

  @Test(arguments: VerifiableCredential.ProgressState.allCases.filter { $0 != .accepted })
  func callAsFunction_notAcceptedCredential_returnsCredentialAsIs(status: VerifiableCredential.ProgressState) async throws {
    var credential = credential
    credential.progressionState = status

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == credential)
    #expect(!holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCalled)
    #expect(!credentialRepository.updateVerifiableCredentialCalled)
  }

  @Test
  func callAsFunction_noRefreshToken_returnsCredentialAsIs() async throws {
    let credential = Self.createCredential(refreshToken: nil)

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == credential)
    #expect(!holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCalled)
    #expect(!credentialRepository.updateVerifiableCredentialCalled)
  }

  @Test(arguments: CredentialStatus.allCases.filter { $0 != .revoked })
  func callAsFunction_notRevokedCredential_refreshesCredential(status: CredentialStatus) async throws {
    credentialStatusValidator.callAsFunctionReturnValue = status

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == checkedCredential)
    #expect(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCalled)
    #expect(credentialRepository.updateVerifiableCredentialCalled)
  }

  @Test
  func callAsFunction_revokedCredential_returnsCredentialAsIs() async throws {
    credentialStatusValidator.callAsFunctionReturnValue = .revoked

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == credential)
    #expect(!holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCalled)
    #expect(!credentialRepository.updateVerifiableCredentialCalled)
  }

  @Test
  func callAsFunction_refreshDisabled_returnsCredentialAsIs() async throws {
    var metadata = CredentialIssuerMetadata.Mock.sample
    metadata.credentialConfigurationsSupported = metadata.credentialConfigurationsSupported.mapValues {
      var config = $0 as! CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported
      config.credentialRefreshDisabled = true
      return config
    }
    let metadataJws = CredentialIssuerMetadataJWT.Mock.createJWS(from: metadata)
    openIDRepository.fetchMetadataFromReturnValue = metadataJws

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == credential)
    #expect(!holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCalled)
    #expect(!credentialRepository.updateVerifiableCredentialCalled)
  }

  @Test
  func callAsFunction_currentCredentialHasNoProfile_refreshesCredential() async throws {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = nil
    swissProfileStatusEvaluator.callAsFunctionAnyCredentialReturnValue = .endOfLife

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == checkedCredential)
  }

  @Test
  func callAsFunction_refreshCredentialHasNewerProfile_refreshesCredential() async throws {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = .endOfLife
    swissProfileStatusEvaluator.callAsFunctionAnyCredentialReturnValue = .deprecated

    let refreshedCredential = try await useCase(credential)

    #expect(refreshedCredential == checkedCredential)
  }

  @Test
  func callAsFunction_refreshCredentialHasOlderProfile_throws() async throws {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = .current
    swissProfileStatusEvaluator.callAsFunctionAnyCredentialReturnValue = .deprecated

    await #expect(throws: RefreshVerifiableCredentialUseCaseError.invalidSwissProfile) {
      _ = try await useCase(credential)
    }
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
    #expect(credentialKeyRepository.deleteCallsCount == holderBindings.count)
    #expect(credentialKeyRepository.deleteReceivedInvocations == holderBindings.map(\.keyPair))
  }

  @Test
  func callAsFunction_refreshCredentialHasNoProfile_throws() async throws {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = .current
    swissProfileStatusEvaluator.callAsFunctionAnyCredentialReturnValue = nil

    await #expect(throws: RefreshVerifiableCredentialUseCaseError.invalidSwissProfile) {
      _ = try await useCase(credential)
    }
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
    #expect(credentialKeyRepository.deleteCallsCount == holderBindings.count)
    #expect(credentialKeyRepository.deleteReceivedInvocations == holderBindings.map(\.keyPair))
  }

  @Test
  func callAsFunction_deferredResponse_throws() async throws {
    refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(DeferredCredentialContext.Mock.sample),
      authorization: IssuanceAuthorization(accessToken: refreshedAccessToken))

    do {
      _ = try await useCase(credential)
      Issue.record("Expected deferredCredentialResponseNotSupported")
    } catch RefreshVerifiableCredentialUseCaseError.deferredCredentialResponseNotSupported {
      #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
      #expect(credentialKeyRepository.deleteCallsCount == holderBindings.count)
      #expect(credentialKeyRepository.deleteReceivedInvocations == holderBindings.map(\.keyPair))
    } catch {
      Issue.record("Expected deferredCredentialResponseNotSupported, got \(error)")
    }
  }

  @Test
  func callAsFunction_refreshFails_deletesHolderBindings() async {
    let secondKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let generatedHolderBindings = holderBindings + [HolderBinding(keyPair: secondKeyPair)]
    holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReturnValue = generatedHolderBindings
    refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      #expect(error as? TestingError == .error)
    }

    #expect(credentialKeyRepository.deleteCallsCount == generatedHolderBindings.count)
    #expect(credentialKeyRepository.deleteReceivedInvocations == generatedHolderBindings.map(\.keyPair))
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
  }

  @Test
  func callAsFunction_credentialDidNotSameAsMetadata_throwsUnverifiedActor() async throws {
    actorIdentityValidator.validateIssuerDidMetadataJwsThrowableError = GovernanceError.unverifiedActor

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      #expect(error as? GovernanceError == .unverifiedActor)
      #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
    }
  }

  @Test
  func callAsFunction_invalidActorIdentity_terminatesInteraction() async throws {
    actorIdentityValidator.validateThrowableError = GovernanceError.unverifiedActor

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      #expect(error as? GovernanceError == .unverifiedActor)
      #expect(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCallsCount == 0)
      #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationCallsCount == 0)
      #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
    }
  }

  @Test
  func callAsFunction_protectedIssuanceValidatorThrows_throws() async throws {
    protectedIssuanceValidator.validateAnyCredentialMetadataWrapperThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      #expect(error as? TestingError == .error)
      #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.lastRefreshAttemptAt == Self.dateMock)
    }
  }

  @Test
  func callAsFunction_success_deletesStaleKeyBindingsAfterSavingCredential() async throws {
    let refreshedCredential = credentialWith(bundleItems: [
      BundleItem(payload: CredentialPayload.Mock.default, keyBinding: Self.refreshedKeyBinding),
    ])
    credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReturnValue = refreshedCredential
    credentialRepository.updateVerifiableCredentialReturnValue = refreshedCredential
    checkAndUpdateCredentialStatusUseCase.callAsFunctionForReturnValue = refreshedCredential

    _ = try await useCase(credential)

    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 1)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmCallsCount == 1)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier == Self.keyBinding.id.uuidString)
    let expectedAlgorithm = try VaultAlgorithm(fromSignatureAlgorithm: Self.keyBinding.algorithm)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm == expectedAlgorithm)
    #expect(credentialKeyRepository.deleteCallsCount == 0)
  }

  @Test
  func callAsFunction_batchResponse_validatesIssuerDid() async throws {
    refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      authorization: IssuanceAuthorization(accessToken: refreshedAccessToken))
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = [
      CredentialWithKeyBinding(credential: anyCredential, keyBinding: Self.refreshedKeyBinding),
    ]

    _ = try await useCase(credential)

    #expect(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount == 1)
    #expect(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid == anyCredential.issuer)
  }

  // MARK: Private

  private static let dateMock = Date(timeIntervalSince1970: 1_700_000_000)
  private static let refreshedKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
  private static let refreshedKeyBinding = KeyBinding(
    id: UUID(),
    algorithm: refreshedKeyPair.algorithm.rawValue,
    bindingType: .software,
    publicKey: try! refreshedKeyPair.publicKey?.toData(),
    privateKey: try! refreshedKeyPair.privateKey.toData())

  private static let metadataJwsMock = CredentialIssuerMetadataJWT.Mock.sample
  private static let keyBinding = KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)

  private let anyCredential: AnyCredential = MockAnyCredential()
  private let generatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty
  private let savedCredential: VerifiableCredential = .Mock.sample
  private let checkedCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let refreshedAccessToken = AccessToken(
    accessToken: "refreshed-access-token",
    tokenType: .bearer,
    refreshToken: "refreshed-refresh-token")
  private let dpopKeyBinding = KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)
  private let secondRefreshedKeyBinding = KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)
  private let holderBindings = [HolderBinding(keyPair: refreshedKeyPair)]
  private let rawOcaBundle = "rawOcaBundle".data(using: .utf8)!

  private var useCase: RefreshVerifiableCredentialUseCase!

  private var credentialStatusValidator: CredentialStatusValidatorProtocolSpy!
  private var openIDRepository: OpenIDRepositoryProtocolSpy!
  private var refreshAnyCredentialUseCase: RefreshAnyVerifiableCredentialUseCaseProtocolSpy!
  private var holderBindingsGenerator: HolderBindingsGeneratorProtocolSpy!
  private var keyManager: KeyManagerProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var credentialKeyRepository: CredentialKeyRepositoryProtocolSpy!
  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var analyticsProvider: MockProvider!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var keyBindingGenerator: KeyBindingGeneratorProtocolSpy!
  private var protectedIssuanceValidator: ProtectedIssuanceValidatorProtocolSpy!
  private var actorIdentityValidator: ActorIdentityValidatorProtocolSpy!
  private var swissProfileStatusEvaluator: SwissProfileStatusEvaluatorProtocolSpy!

  private var credential = createCredential()

  private static func createCredential(refreshToken: String? = "stored-refresh-token") -> VerifiableCredential {
    var credential = VerifiableCredential.Mock.sampleWithoutKeyBinding
    credential.bundleItems = [BundleItem(payload: CredentialPayload.Mock.default, keyBinding: keyBinding)]
    credential.authentication = CredentialAuthentication(accessToken: "stored-access-token", refreshToken: refreshToken)
    credential.issuerUrl = metadataJwsMock.payload.credentialIssuerMetadata.credentialIssuer
    credential.selectedConfigurationId = CredentialIssuerMetadataWrapper.Mock.sample.credentialConfigurationId
    return credential
  }

  private mutating func registerMocks() {
    let credentialStatusValidator = CredentialStatusValidatorProtocolSpy()
    let openIDRepository = OpenIDRepositoryProtocolSpy()
    let refreshAnyCredentialUseCase = RefreshAnyVerifiableCredentialUseCaseProtocolSpy()
    let holderBindingsGenerator = HolderBindingsGeneratorProtocolSpy()
    let keyManager = KeyManagerProtocolSpy()
    let fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    let credentialGenerator = CredentialGeneratorProtocolSpy()
    let credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()
    let credentialRepository = CredentialRepositoryProtocolSpy()
    let analyticsProvider = MockProvider()
    let analytics = Analytics()
    analytics.register(analyticsProvider)
    let checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    let mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    let keyBindingGenerator = KeyBindingGeneratorProtocolSpy()
    let protectedIssuanceValidator = ProtectedIssuanceValidatorProtocolSpy()
    let actorIdentityValidator = ActorIdentityValidatorProtocolSpy()
    let swissProfileStatusEvaluator = SwissProfileStatusEvaluatorProtocolSpy()

    self.credentialStatusValidator = credentialStatusValidator
    self.openIDRepository = openIDRepository
    self.refreshAnyCredentialUseCase = refreshAnyCredentialUseCase
    self.holderBindingsGenerator = holderBindingsGenerator
    self.keyManager = keyManager
    self.fetchVcMetadataUseCase = fetchVcMetadataUseCase
    self.credentialGenerator = credentialGenerator
    self.credentialKeyRepository = credentialKeyRepository
    self.credentialRepository = credentialRepository
    self.analyticsProvider = analyticsProvider
    self.checkAndUpdateCredentialStatusUseCase = checkAndUpdateCredentialStatusUseCase
    self.mapCredentialsToKeyBindingsUseCase = mapCredentialsToKeyBindingsUseCase
    self.keyBindingGenerator = keyBindingGenerator
    self.protectedIssuanceValidator = protectedIssuanceValidator
    self.actorIdentityValidator = actorIdentityValidator
    self.swissProfileStatusEvaluator = swissProfileStatusEvaluator

    Container.shared.credentialStatusValidator.register { credentialStatusValidator }
    Container.shared.openIDRepository.register { openIDRepository }
    Container.shared.refreshAnyVerifiableCredentialUseCase.register { refreshAnyCredentialUseCase }
    Container.shared.holderBindingsGenerator.register { holderBindingsGenerator }
    Container.shared.keyManager.register { keyManager }
    Container.shared.fetchVcMetadataUseCase.register { fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { credentialGenerator }
    Container.shared.credentialKeyRepository.register { credentialKeyRepository }
    Container.shared.credentialRepository.register { credentialRepository }
    Container.shared.analytics.register { analytics }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { checkAndUpdateCredentialStatusUseCase }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { mapCredentialsToKeyBindingsUseCase }
    Container.shared.keyBindingGenerator.register { keyBindingGenerator }
    Container.shared.protectedIssuanceValidator.register { protectedIssuanceValidator }
    Container.shared.actorIdentityValidator.register { actorIdentityValidator }
    Container.shared.swissProfileStatusEvaluator.register { swissProfileStatusEvaluator }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:tdw:mock=:mock\.swiyu\.admin\.ch:.*/# }
    Container.shared.currentDate.register { Self.dateMock }
  }

  private func createSuccessState() {
    credentialStatusValidator.callAsFunctionReturnValue = .valid
    openIDRepository.fetchMetadataFromReturnValue = Self.metadataJwsMock
    refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      authorization: IssuanceAuthorization(accessToken: refreshedAccessToken))
    holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReturnValue = holderBindings
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = [CredentialWithKeyBinding(credential: anyCredential, keyBinding: Self.refreshedKeyBinding)]
    keyManager.getExternalRepresentationOfReturnValue = (
      rawPublicKey: try! Self.refreshedKeyPair.publicKey!.toData(),
      rawPrivateKey: try! Self.refreshedKeyPair.privateKey.toData())
    keyBindingGenerator.generateFromReturnValue = dpopKeyBinding
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundle
    credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReturnValue = generatedCredential
    credentialRepository.updateVerifiableCredentialReturnValue = savedCredential
    checkAndUpdateCredentialStatusUseCase.callAsFunctionForReturnValue = checkedCredential
    swissProfileStatusEvaluator.callAsFunctionAnyCredentialReturnValue = .current
  }

  private func credentialWith(bundleItems: [BundleItem]) -> VerifiableCredential {
    var credential = generatedCredential
    credential.bundleItems = bundleItems
    if let nextPresentableBundleItemId = bundleItems.first?.id {
      credential.nextPresentableBundleItemId = nextPresentableBundleItemId
    }
    return credential
  }
}
