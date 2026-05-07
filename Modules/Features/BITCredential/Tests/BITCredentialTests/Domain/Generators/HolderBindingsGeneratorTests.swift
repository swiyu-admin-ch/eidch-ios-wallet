import Factory
import XCTest
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCredential
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

final class HolderBindingsGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    userSession.context = mockContext
    registerMocks()
    success()

    analyticsProvider = MockProvider()
    analytics = Analytics()
    analytics.register(analyticsProvider)

    generator = HolderBindingsGenerator()
  }

  func testGenerate_metadataWithoutProofTypes_returnsEmpty() async throws {
    let bindings = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleWithoutProofTypes)

    XCTAssertFalse(credentialKeyRepository.createAlgorithmIsHardwareBoundCalled)
    XCTAssert(bindings.isEmpty)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_metadataWithProofTypesNoKeyAttestationRequired_returnsValidContext() async throws {
    let softwareBoundKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = softwareBoundKeyPair
    generator = HolderBindingsGenerator()

    let bindings = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sample)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, false)
    XCTAssertEqual(bindings.first?.keyPair, softwareBoundKeyPair)
    XCTAssertNil(bindings.first?.keyAttestationJWS)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_metadataWithKeyAttestationRequired_returnsValidContext() async throws {
    let bindings = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleKeyAttestationRequired)

    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
    XCTAssertEqual(bindings.first?.keyPair, mockKeyPair)
    XCTAssertEqual(bindings.first?.keyAttestationJWS, mockKeyAttestation.rawJWS)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_incorrectPreferredAlgorithms_throwsUnsupportedAlgorithm() async throws {
    let mockPreferredAlgos = [JWTAlgorithm.ES384]
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { mockPreferredAlgos }

    generator = HolderBindingsGenerator()

    try await assertUnsupportedAlgorithmException(for: mockMetadataWrapper, preferredAlgos: mockPreferredAlgos)
  }

  func testGenerate_noMatchablePreferredAlgorithms_throwsUnsupportedAlgorithm() async throws {
    let mockPreferredAlgos = [JWTAlgorithm]()
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { mockPreferredAlgos }

    generator = HolderBindingsGenerator()

    try await assertUnsupportedAlgorithmException(for: mockMetadataWrapper, preferredAlgos: mockPreferredAlgos)
  }

  func testGenerate_keyAttestationUseCaseThrowsError_throwsError() async {
    appAttestationRepository.fetchKeyAttestationBodyClientAttestationThrowableError = TestingError.error

    do {
      _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleKeyAttestationRequired)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_keyAttestationInvalid_throwsError() async {
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = false

    do {
      _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleKeyAttestationRequired)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .invalidKeyAttestation)
    }
  }

  func testGenerate_credentialKeyPairGeneratorThrowsError_throwsErrorAndLoggs() async {
    credentialKeyRepository.createAlgorithmIsHardwareBoundThrowableError = TestingError.error

    generator = HolderBindingsGenerator()

    do {
      _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleKeyAttestationRequired)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(analyticsProvider.logCounter, 1)
    }
  }

  func testGenerate_preferredKeyBindingAlgorithmPriorisation_receivesHighesPrioAlgorithm() async throws {
    let preferredAlgorithms: [JWTAlgorithm] = [.ES512, .ES384, .ES512]
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { preferredAlgorithms }

    guard let supportedAlgos = mockMetadataWrapper.selectedCredential.proofTypesSupported.first?.algorithms else {
      fatalError("Cannot extract supported algorithms")
    }

    generator = HolderBindingsGenerator()

    _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleKeyAttestationRequired)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.algorithm, JWTAlgorithm.ES512.rawValue)
    XCTAssertTrue(supportedAlgos.contains { self.mockpreferredKeyBindingAlgorithmsOrdered.map(\.rawValue).contains($0) })
  }

  func testGenerate_metadataWithEmptyKeyStorage_keyPairGeneratedWithSecureEnclave() async throws {
    _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleEmptyKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_multipleSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate, .iso18045High] }

    generator = HolderBindingsGenerator()

    _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleMultipleKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_mixedSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate] }

    generator = HolderBindingsGenerator()

    _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sampleMultipleKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testGenerate_batchMetadata_generatesDefaultOne() async throws {
    let metadataWrapper = CredentialIssuerMetadataWrapper.Mock.sample

    let bindings = try await generator(from: metadataWrapper)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(bindings.count, 1)
  }

  func testGenerate_batchMetadata_generatesMultipleBindings() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    generator = HolderBindingsGenerator()
    let metadataWrapper = CredentialIssuerMetadataWrapper.Mock.sampleBatch

    let bindings = try await generator(from: metadataWrapper)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 10)
    XCTAssertEqual(bindings.count, 10)
  }

  func testGenerate_batchMetadata_whenBatchIssuanceDisabled_generatesSingleBinding() async throws {
    Container.shared.isBatchIssuanceEnabled.register { false }
    generator = HolderBindingsGenerator()
    let metadataWrapper = CredentialIssuerMetadataWrapper.Mock.sampleBatch

    let bindings = try await generator(from: metadataWrapper)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(bindings.count, 1)
  }

  // MARK: Private

  private var generator = HolderBindingsGenerator()

  private var mockContext = LAContextProtocolSpy()
  private let mockMetadataWrapper = CredentialIssuerMetadataWrapper.Mock.sample
  private let mockpreferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm] = [.ES256]
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockSupportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel] = [.iso18045High]
  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample
  private let mockClientAttestation = ClientAttestationJWT.Mock.sample

  private var appAttestationRepository = AppAttestationRepositoryProtocolSpy()
  private var clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
  private var keyAttestationValidator = KeyAttestationValidatorProtocolSpy()
  private var credentialKeyRepository = CredentialKeyRepositoryProtocolSpy()
  private var userSession = SessionSpy()

  // swiftlint:disable all
  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!

  // swiftlint:enable all

  private func registerMocks() {
    Container.shared.userSession.register { self.userSession }
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { self.mockpreferredKeyBindingAlgorithmsOrdered }
    Container.shared.credentialKeyRepository.register { self.credentialKeyRepository }
    Container.shared.supportedKeyStorageSecurityLevel.register { self.mockSupportedKeyStorageSecurityLevel }
    Container.shared.appAttestationRepository.register { self.appAttestationRepository }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
    Container.shared.analytics.register { self.analytics }
  }

  private func success() {
    appAttestationRepository.fetchKeyAttestationBodyClientAttestationReturnValue = mockKeyAttestation
    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = true
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = mockKeyPair
  }

  private func assertUnsupportedAlgorithmException(for metadataWrapper: CredentialIssuerMetadataWrapper, preferredAlgos: [JWTAlgorithm]) async throws {
    guard let supportedAlgos = metadataWrapper.selectedCredential.proofTypesSupported.first?.algorithms else {
      fatalError("Cannot extract supported algorithms")
    }

    do {
      _ = try await generator(from: CredentialIssuerMetadataWrapper.Mock.sample)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.unsupportedAlgorithm {
      XCTAssertFalse(supportedAlgos.contains { preferredAlgos.map(\.rawValue).contains($0) })
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    } catch {
      XCTFail("Not the expected error")
    }
  }
}
