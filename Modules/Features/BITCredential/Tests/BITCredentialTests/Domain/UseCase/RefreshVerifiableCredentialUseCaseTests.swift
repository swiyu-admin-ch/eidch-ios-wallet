import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

@Suite(.serialized)
struct RefreshVerifiableCredentialUseCaseTests {

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
    #expect(openIDRepository.fetchMetadataFromReceivedIssuerUrl?.absoluteString == credential.issuerUrl)

    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationCallsCount == 1)
    #expect(
      refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.metadataWrapper.credentialConfigurationId ==
        credential.selectedConfigurationId)
    #expect(holderBindingsGenerator.callAsFunctionFromCallsCount == 1)
    #expect(holderBindingsGenerator.callAsFunctionFromReceivedMetadataWrapper?.credentialConfigurationId == credential.selectedConfigurationId)
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.holderBindings?.count == 1)
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.holderBindings == holderBindings)
    #expect(keyBindingGenerator.generateFromCallsCount == 2)
    let expectedAuthorization = IssuanceAuthorization(
      accessToken: AccessToken(
        accessToken: credential.authentication.accessToken,
        tokenType: credential.authentication.tokenType,
        refreshToken: credential.authentication.refreshToken))
    #expect(refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReceivedArguments?.authorization == expectedAuthorization)

    #expect(fetchVcMetadataUseCase.executeAnyCredentialCallsCount == 1)
    #expect(fetchVcMetadataUseCase.executeAnyCredentialReceivedAnyCredential?.raw == anyCredential.raw)

    #expect(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationCallsCount == 1)
    #expect(
      credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.credentialsWithKeyBinding.first?.keyBinding ==
        refreshedKeyBinding)
    let expectedAuthentication = CredentialAuthentication(
      accessToken: refreshedAccessToken.accessToken,
      tokenType: refreshedAccessToken.tokenType,
      refreshToken: refreshedAccessToken.refreshToken)
    #expect(credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReceivedArguments?.authentication == expectedAuthentication)

    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 1)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.id == credential.id)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.createdAt == credential.createdAt)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.refreshedAt != nil)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.authentication.accessToken == refreshedAccessToken.accessToken)

    #expect(checkAndUpdateCredentialStatusUseCase.executeForCallsCount == 1)
    #expect(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential == savedCredential)
    #expect(refreshedCredential == checkedCredential)
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
      #expect(!credentialRepository.updateVerifiableCredentialCalled)
    } catch {
      Issue.record("Expected deferredCredentialResponseNotSupported, got \(error)")
    }
  }

  @Test
  func callAsFunction_success_deletesStaleKeyBindingsAfterSavingCredential() async throws {
    let refreshedCredential = credentialWith(bundleItems: [
      BundleItem(payload: CredentialPayload.Mock.default, keyBinding: refreshedKeyBinding),
    ])
    credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReturnValue = refreshedCredential
    credentialRepository.updateVerifiableCredentialReturnValue = refreshedCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = refreshedCredential

    _ = try await useCase(credential)

    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 1)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmCallsCount == 1)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier == keyBinding.id.uuidString)
    let expectedAlgorithm = try VaultAlgorithm(fromSignatureAlgorithm: keyBinding.algorithm)
    #expect(keyManager.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm == expectedAlgorithm)
  }

  // MARK: Private

  private let anyCredential: AnyCredential = MockAnyCredential()
  private let metadataResponse = CredentialIssuerMetadataResponse(
    metadata: CredentialIssuerMetadata.Mock.sample,
    raw: CredentialIssuerMetadata.Mock.sampleData)
  private let generatedCredential: VerifiableCredential = .Mock.sampleDisplaysEmpty
  private let savedCredential: VerifiableCredential = .Mock.sample
  private let checkedCredential: VerifiableCredential = .Mock.sampleWithoutKeyBinding
  private let refreshedAccessToken = AccessToken(
    accessToken: "refreshed-access-token",
    tokenType: .bearer,
    refreshToken: "refreshed-refresh-token")
  private let rawOcaBundle = "rawOcaBundle".data(using: .utf8)!
  private let trustInformation = TrustInformation.Mock.trustedIdentity

  private var useCase: RefreshVerifiableCredentialUseCase!
  private var openIDRepository: OpenIDRepositoryProtocolSpy!
  private var refreshAnyCredentialUseCase: RefreshAnyVerifiableCredentialUseCaseProtocolSpy!
  private var holderBindingsGenerator: HolderBindingsGeneratorProtocolSpy!
  private var keyManager: KeyManagerProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var trustInformationService: TrustInformationServiceProtocolSpy!
  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var mapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocolSpy!
  private var keyBindingGenerator: KeyBindingGeneratorProtocolSpy!

  private var credential: VerifiableCredential!
  private var keyPair: VaultKeyPair!
  private var refreshedKeyPair: VaultKeyPair!
  private var secondRefreshedKeyPair: VaultKeyPair!
  private var keyBinding: KeyBinding!
  private var refreshedKeyBinding: KeyBinding!
  private var secondRefreshedKeyBinding: KeyBinding!
  private var holderBindings: [HolderBinding]!

  private mutating func registerMocks() {
    let openIDRepository = OpenIDRepositoryProtocolSpy()
    let refreshAnyCredentialUseCase = RefreshAnyVerifiableCredentialUseCaseProtocolSpy()
    let holderBindingsGenerator = HolderBindingsGeneratorProtocolSpy()
    let keyManager = KeyManagerProtocolSpy()
    let fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    let credentialGenerator = CredentialGeneratorProtocolSpy()
    let trustInformationService = TrustInformationServiceProtocolSpy()
    let credentialRepository = CredentialRepositoryProcotolSpy()
    let checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    let mapCredentialsToKeyBindingsUseCase = MapCredentialsToKeyBindingsUseCaseProtocolSpy()
    let keyBindingGenerator = KeyBindingGeneratorProtocolSpy()

    let keyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let refreshedKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let secondRefreshedKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    let keyBinding = createKeyBinding(from: keyPair)
    let refreshedKeyBinding = createKeyBinding(from: refreshedKeyPair)
    let secondRefreshedKeyBinding = createKeyBinding(from: secondRefreshedKeyPair)
    let holderBindings = [HolderBinding(keyPair: refreshedKeyPair)]

    self.openIDRepository = openIDRepository
    self.refreshAnyCredentialUseCase = refreshAnyCredentialUseCase
    self.holderBindingsGenerator = holderBindingsGenerator
    self.keyManager = keyManager
    self.fetchVcMetadataUseCase = fetchVcMetadataUseCase
    self.credentialGenerator = credentialGenerator
    self.trustInformationService = trustInformationService
    self.credentialRepository = credentialRepository
    self.checkAndUpdateCredentialStatusUseCase = checkAndUpdateCredentialStatusUseCase
    self.mapCredentialsToKeyBindingsUseCase = mapCredentialsToKeyBindingsUseCase
    self.keyBindingGenerator = keyBindingGenerator

    self.keyPair = keyPair
    self.refreshedKeyPair = refreshedKeyPair
    self.secondRefreshedKeyPair = secondRefreshedKeyPair
    self.keyBinding = keyBinding
    self.refreshedKeyBinding = refreshedKeyBinding
    self.secondRefreshedKeyBinding = secondRefreshedKeyBinding
    self.holderBindings = holderBindings

    var credential = VerifiableCredential.Mock.sampleWithoutKeyBinding
    credential.bundleItems = [BundleItem(payload: CredentialPayload.Mock.default, keyBinding: keyBinding)]
    credential.authentication = CredentialAuthentication(accessToken: "stored-access-token", refreshToken: "stored-refresh-token")
    credential.issuerUrl = metadataResponse.metadata.credentialIssuer
    credential.selectedConfigurationId = CredentialIssuerMetadataWrapper.Mock.sample.credentialConfigurationId
    self.credential = credential

    Container.shared.openIDRepository.register { openIDRepository }
    Container.shared.refreshAnyVerifiableCredentialUseCase.register { refreshAnyCredentialUseCase }
    Container.shared.holderBindingsGenerator.register { holderBindingsGenerator }
    Container.shared.keyManager.register { keyManager }
    Container.shared.fetchVcMetadataUseCase.register { fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { credentialGenerator }
    Container.shared.trustInformationService.register { trustInformationService }
    Container.shared.credentialRepository.register { credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { checkAndUpdateCredentialStatusUseCase }
    Container.shared.mapCredentialsToKeyBindingsUseCase.register { mapCredentialsToKeyBindingsUseCase }
    Container.shared.keyBindingGenerator.register { keyBindingGenerator }
  }

  private func createSuccessState() {
    openIDRepository.fetchMetadataFromReturnValue = metadataResponse
    refreshAnyCredentialUseCase.callAsFunctionMetadataWrapperHolderBindingsAuthorizationReturnValue = FetchAnyCredentialResult(
      credentials: .credential(anyCredential),
      authorization: IssuanceAuthorization(accessToken: refreshedAccessToken))
    holderBindingsGenerator.callAsFunctionFromReturnValue = holderBindings
    keyManager.getExternalRepresentationOfReturnValue = (
      rawPublicKey: try! refreshedKeyPair.publicKey!.toData(),
      rawPrivateKey: try! refreshedKeyPair.privateKey.toData())
    keyBindingGenerator.generateFromClosure = { keyPair in
      guard let keyPair else { return nil }
      return createKeyBinding(from: keyPair)
    }
    fetchVcMetadataUseCase.executeAnyCredentialReturnValue = rawOcaBundle
    credentialGenerator.generateForRawOcaBundleMetadataWrapperTrustStatementAuthenticationReturnValue = generatedCredential
    trustInformationService.fetchForTypeVcSchemaIdReturnValue = trustInformation
    credentialRepository.updateVerifiableCredentialReturnValue = savedCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = checkedCredential
  }

  private func createKeyBinding(from keyPair: VaultKeyPair) -> KeyBinding {
    KeyBinding(
      id: UUID(uuidString: keyPair.identifier) ?? UUID(),
      algorithm: keyPair.algorithm.rawValue,
      bindingType: .software,
      publicKey: try! keyPair.publicKey?.toData(),
      privateKey: try! keyPair.privateKey.toData())
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

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
