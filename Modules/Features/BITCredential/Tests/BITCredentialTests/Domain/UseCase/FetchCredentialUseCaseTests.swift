import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITAnalytics
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITJWT
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
    let credential = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
  }

  func testExecute_validResultDeferredCredential_returns() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCredentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    let credential = try await useCase.execute(from: offer)

    if let deferredCredential = credential as? DeferredCredential {
      XCTAssertEqual(deferredCredential.authentication.accessToken, mockDeferredCredentialRequest.accessToken.accessToken)
      XCTAssertEqual(deferredCredential.endpoint, mockDeferredCredentialRequest.endpoint)
      XCTAssertEqual(deferredCredential.transactionId, mockDeferredCredentialRequest.transactionId)
      XCTAssertEqual(deferredCredential.format, mockDeferredCredentialRequest.format)

      XCTAssertEqual(fetchVcMetadataUseCase.executeMetadataCallsCount, 1)
      XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationCallsCount, 1)
      XCTAssertEqual(actorIdentityValidator.validateCallsCount, 1)
      XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount, 0)
      XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 0)
      XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 0)
    }
  }

  func testExecute_validResultDeferredCredential_argumentsPassed() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCredentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(openIdRepositorySpy.fetchMetadataFromReceivedIssuerUrl, offer.issuer)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.batchSize, Self.metadataJws.payload.credentialIssuerMetadata.batchCredentialIssuance?.batchSize)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.proofTypes, Self.metadataJws.payload.credentialIssuerMetadata.credentialConfigurationsSupported.first?.value.proofTypesSupported)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.metadataWrapper.metadataJws, Self.metadataJws)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.holderBindings, mockHolderBindings)

    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.deferredCredentialContext, mockDeferredCredentialRequest)
    XCTAssertEqual(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.keyBindings, [mockCredentialKeyBinding])
    XCTAssertEqual(
      credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.metadataWrapper.metadataJws, Self.metadataJws)
    XCTAssertNotNil(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(
      credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.accessToken,
      mockDeferredCredentialRequest.accessToken.accessToken)
    XCTAssertEqual(
      credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.refreshToken,
      mockDeferredCredentialRequest.accessToken.refreshToken)
  }

  func testExecute_validResultDeferredCredential_passesAllKeyBindingsToGenerator() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .deferred(mockDeferredCredentialRequest),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReturnValue = HolderBinding.Mock.batch

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      Set(credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.keyBindings.map(\.id.uuidString) ?? []),
      Set(HolderBinding.Mock.batch.map(\.keyPair.identifier)))
  }

  func testExecute_validResultCredential_callsCount() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(openIdRepositorySpy.fetchMetadataFromCallsCount, 1)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount, 1)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCallsCount, 1)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsCallsCount, 1)
    XCTAssertEqual(keyBindingGenerator.generateFromCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialCallsCount, 1)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationCallsCount, 1)
    XCTAssertEqual(credentialRepository.createVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
  }

  func testExecute_validResultCredential_argumentsPassed() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(openIdRepositorySpy.fetchMetadataFromReceivedIssuerUrl, offer.issuer)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.batchSize, Self.metadataJws.payload.credentialIssuerMetadata.batchCredentialIssuance?.batchSize)
    XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReceivedArguments?.proofTypes, Self.metadataJws.payload.credentialIssuerMetadata.credentialConfigurationsSupported.first?.value.proofTypesSupported)
    XCTAssertEqual(actorIdentityValidator.validateReceivedMetadataJws, Self.metadataJws)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid, anyCredential.issuer)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.metadataJws, Self.metadataJws)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.offer, offer)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.metadataWrapper.metadataJws, Self.metadataJws)
    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReceivedArguments?.holderBindings, mockHolderBindings)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.credential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, mockCredentialKeyBinding)
    XCTAssertNotNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.metadataWrapper.metadataJws, Self.metadataJws)

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
  }

  func testExecute_validResultCredential_passesRefreshTokenToCredentialGenerator() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: "refresh-token")

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.refreshToken,
      "refresh-token")
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.accessToken,
      mockAccessToken)
  }

  func testExecute_immediateCredentialWithDPoP_persistsBindingAndKeepsKey() async throws {
    let dpopKeyPair = VaultKeyPair.Mock.ES256
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .dpop,
      refreshToken: nil,
      dpopKeyPair: dpopKeyPair)

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(issuanceDPoPKeyRepository.deleteCallsCount, 0)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.dpopBinding?.id.uuidString,
      dpopKeyPair.identifier)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.dpopBinding?.algorithm,
      dpopKeyPair.algorithm.rawValue)
  }

  func testExecute_fetchOCAReturnsNil_passesNilAndReturnsBoth() async throws {
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = nil

    let credential = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)

    XCTAssertNil(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.rawOcaBundle)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
  }

  func testExecute_fetchMetadataFails_throwsError() async throws {
    openIdRepositorySpy.fetchMetadataFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_holderBindingsGeneratorFails_throwsError() async throws {
    holderBindingsGenerator.callAsFunctionBatchSizeProofTypesThrowableError = TestingError.error

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
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
    }
  }

  func testExecute_batchResultWithoutBatchMetadata_throwsInvalidCredentialAndDeletesKey() async throws {
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential, anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a FetchCredentialUseCaseError.invalidCredential instead")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
    }
  }

  func testExecute_validBatchResult_returnsBothAndMapsCredentialsToKeyBindings() async throws {
    let metadataWithBatchSize = CredentialIssuerMetadataJWT.Mock.sample

    openIdRepositorySpy.fetchMetadataFromReturnValue = metadataWithBatchSize
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)

    let credential = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, updatedCredential)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsCallsCount, 1)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReceivedArguments?.credentials.first?.raw, anyCredential.raw)
    XCTAssertEqual(mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReceivedArguments?.keyPairs.first?.identifier, mockHolderBindings.first?.keyPair.identifier)
    XCTAssertEqual(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication,
      CredentialAuthentication(accessToken: mockAccessToken))
  }

  func testExecute_validBatchResult_validatesIssuerDid() async throws {
    openIdRepositorySpy.fetchVcSchemaDataFromReturnValue = CredentialIssuerMetadataJWT.Mock.sampleData
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = [
      CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding),
    ]

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsCallsCount, 1)
    XCTAssertEqual(actorIdentityValidator.validateIssuerDidMetadataJwsReceivedArguments?.issuerDid, anyCredential.issuer)
  }

  func testExecute_validBatchResult_passesRefreshTokenToCredentialGenerator() async throws {
    let metadataWithBatchSize = CredentialIssuerMetadataJWT.Mock.sample
    let mappedCredential = CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)

    openIdRepositorySpy.fetchMetadataFromReturnValue = metadataWithBatchSize
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: "refresh-token")
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = [mappedCredential]

    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.refreshToken,
      "refresh-token")
    XCTAssertEqual(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReceivedArguments?.authentication.accessToken,
      mockAccessToken)
  }

  func testExecute_batchResultWithNoMappedCredential_throwsInvalidCredentialAndDeletesKey() async throws {
    openIdRepositorySpy.fetchMetadataFromReturnValue = CredentialIssuerMetadataJWT.Mock.sample
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer)
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = []

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a FetchCredentialUseCaseError.invalidCredential instead")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
    }
  }

  func testExecute_credentialDidNotSameAsMetadata_throwsUnverifiedActor() async throws {
    actorIdentityValidator.validateIssuerDidMetadataJwsThrowableError = GovernanceError.unverifiedActor

    await XCTAssertThrowsErrorAsync(try await useCase.execute(from: offer)) { error in
      XCTAssertEqual(error as? GovernanceError, .unverifiedActor)
    }
  }

  func testExecute_invalidActorIdentity_throwsBeforeFetchingCredential() async throws {
    actorIdentityValidator.validateThrowableError = GovernanceError.unverifiedActor

    await XCTAssertThrowsErrorAsync(try await useCase.execute(from: offer)) { error in
      XCTAssertEqual(error as? GovernanceError, .unverifiedActor)
      XCTAssertEqual(holderBindingsGenerator.callAsFunctionBatchSizeProofTypesCallsCount, 0)
      XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsCallsCount, 0)
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

  func testExecute_protectedIssuanceValidatorThrows_throws() async throws {
    protectedIssuanceValidator.validateAnyCredentialMetadataWrapperThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialGeneratorFailure_throwsError() async throws {
    credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationThrowableError = TestingError.error

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

  func testExecute_checkAndUpdateCredentialStatusFailure_returnsValidCredentialAndTrustStatement() async throws {
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error

    let credential = try await useCase.execute(from: offer)

    XCTAssertEqual(credential as? VerifiableCredential, repositoryCredential)
  }

  // MARK: Private

  private static let metadataJws: JWS<CredentialIssuerMetadataJWT> = CredentialIssuerMetadataJWT.Mock.sampleNoBatch

  private var openIdRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var holderBindingsGenerator: HolderBindingsGeneratorProtocolSpy!
  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var credentialKeyRepository: CredentialKeyRepositoryProtocolSpy!
  private var analyticsProvider: MockProvider!
  private var issuanceDPoPKeyRepository: IssuanceDPoPKeyRepositoryProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var keyBindingGenerator: KeyBindingGeneratorProtocolSpy!
  private var trustStatementValidator: TrustStatementValidatorProtocolSpy<IdentityTrustStatementJWT>!
  private var protectedIssuanceValidator: ProtectedIssuanceValidatorProtocolSpy!
  private var actorIdentityValidator: ActorIdentityValidatorProtocolSpy!
  private var useCase: FetchCredentialUseCase!

  private let generatedCredential: VerifiableCredential = .Mock.sample
  private let repositoryCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let updatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let offer: CredentialOffer = .Mock.sample
  private let rawOcaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let mockAccessToken = "access-token"
  private let mockHolderBindings = HolderBinding.Mock.softwareKey
  private let mockDeferredCredentialRequest = DeferredCredentialContext.Mock.sample
  private var mockCredentialKeyBinding: KeyBinding!

  private func registerMocks() {
    openIdRepositorySpy = OpenIDRepositoryProtocolSpy()
    holderBindingsGenerator = HolderBindingsGeneratorProtocolSpy()
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    credentialRepository = CredentialRepositoryProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()
    analyticsProvider = MockProvider()
    let analytics = Analytics()
    analytics.register(analyticsProvider)
    issuanceDPoPKeyRepository = IssuanceDPoPKeyRepositoryProtocolSpy()
    mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    keyBindingGenerator = KeyBindingGeneratorProtocolSpy()
    trustStatementValidator = TrustStatementValidatorProtocolSpy()
    protectedIssuanceValidator = ProtectedIssuanceValidatorProtocolSpy()
    actorIdentityValidator = ActorIdentityValidatorProtocolSpy()
    mockCredentialKeyBinding = try? KeyBinding(
      id: UUID(uuidString: mockHolderBindings.first!.keyPair.identifier)!,
      algorithm: "ES256",
      bindingType: .software,
      publicKey: mockHolderBindings.first?.keyPair.publicKey?.toData(),
      privateKey: mockHolderBindings.first?.keyPair.privateKey.toData())

    Container.shared.openIDRepository.register { self.openIdRepositorySpy }
    Container.shared.holderBindingsGenerator.register { self.holderBindingsGenerator }
    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.credentialKeyRepository.register { self.credentialKeyRepository }
    Container.shared.analytics.register { analytics }
    Container.shared.issuanceDPoPKeyRepository.register { self.issuanceDPoPKeyRepository }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { self.mapCredentialsToKeyBindingsUseCase }
    Container.shared.keyBindingGenerator.register { self.keyBindingGenerator }
    Container.shared.trustStatementValidator.register { self.trustStatementValidator }
    Container.shared.protectedIssuanceValidator.register { self.protectedIssuanceValidator }
    Container.shared.actorIdentityValidator.register { self.actorIdentityValidator }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:tdw:mock=:mock\.swiyu\.admin\.ch:.*/# }

  }

  private func success() {
    openIdRepositorySpy.fetchMetadataFromReturnValue = Self.metadataJws
    holderBindingsGenerator.callAsFunctionBatchSizeProofTypesReturnValue = mockHolderBindings
    fetchAnyVerifiableCredentialUseCase.callAsFunctionFromMetadataWrapperHolderBindingsReturnValue = FetchAnyCredentialResult(
      credentials: .credential([anyCredential]),
      accessToken: mockAccessToken,
      tokenType: .bearer,
      refreshToken: nil)
    fetchVcMetadataUseCase.executeMetadataReturnValue = rawOcaBundleMock
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundleMock
    keyBindingGenerator.generateFromClosure = { keyPair in
      guard let keyPair else { return nil }
      return try KeyBinding(
        id: UUID(uuidString: keyPair.identifier)!,
        algorithm: keyPair.algorithm.rawValue,
        bindingType: keyPair.options?.contains(.secureEnclave) == true ? .hardware : .software,
        publicKey: keyPair.publicKey?.toData(),
        privateKey: keyPair.privateKey.toData())
    }
    let mappedCredential = CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)
    mapCredentialsToKeyBindingsUseCase.callAsFunctionCredentialsKeyPairsReturnValue = [mappedCredential]
    credentialGenerator.generateForRawOcaBundleMetadataWrapperAuthenticationReturnValue = generatedCredential
    credentialRepository.createVerifiableCredentialReturnValue = repositoryCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
    credentialGenerator.generateDeferredKeyBindingsRawOcaBundleMetadataWrapperAuthenticationReturnValue = DeferredCredential(
      transactionId: mockDeferredCredentialRequest.transactionId,
      endpoint: mockDeferredCredentialRequest.endpoint,
      format: mockDeferredCredentialRequest.format,
      issuerUrl: Self.metadataJws.payload.credentialIssuerMetadata.credentialIssuer,
      authentication: CredentialAuthentication(
        accessToken: mockDeferredCredentialRequest.accessToken.accessToken,
        tokenType: mockDeferredCredentialRequest.accessToken.tokenType,
        refreshToken: mockDeferredCredentialRequest.accessToken.refreshToken))
  }
}
