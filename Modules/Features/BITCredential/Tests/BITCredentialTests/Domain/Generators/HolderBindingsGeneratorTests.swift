import Factory
import XCTest
@testable import BITAnalytics
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCredential
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// MARK: - HolderBindingsGeneratorTests

final class HolderBindingsGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    userSession.context = mockContext
    registerMocks()
    success()

    analyticsProvider = MockProvider()
    analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    generator = HolderBindingsGenerator()
  }

  func testGenerate_metadataWithoutProofTypes_returnsEmpty() async throws {
    let bindings = try await generator(batchSize: nil, proofTypes: [])

    XCTAssertFalse(credentialKeyRepository.createAlgorithmIsHardwareBoundCalled)
    XCTAssert(bindings.isEmpty)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_metadataWithProofTypesNoKeyAttestationRequired_returnsValidContext() async throws {
    let softwareBoundKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = softwareBoundKeyPair
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: nil, proofTypes: [.Mock.jwtSoftware256])
    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, false)
    XCTAssertEqual(analyticsProvider.logCounter, 0)

    XCTAssertEqual(bindings.count, 1)
    XCTAssertEqual(bindings.first?.keyPair, softwareBoundKeyPair)
    XCTAssertNil(bindings.first?.keyAttestationJWS)
  }

  func testGenerate_withoutKeyAttestationRequired_withDisabledClientAttestationRepository_returnsValidContext() async throws {
    let softwareBoundKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = softwareBoundKeyPair
    Container.shared.clientAttestationRepository.register { DisabledClientAttestationRepository() }
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: nil, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, false)
    XCTAssertEqual(bindings.first?.keyPair, softwareBoundKeyPair)
    XCTAssertNil(bindings.first?.keyAttestationJWS)
    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 0)
  }

  func testGenerate_metadataWithKeyAttestationRequired_returnsValidContext() async throws {
    let bindings = try await generator(batchSize: nil, proofTypes: [.Mock.jwtHardwareHigh256])

    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
    XCTAssertEqual(bindings.first?.keyPair, mockKeyPair)
    XCTAssertEqual(bindings.first?.keyAttestationJWS, mockKeyAttestation.rawJWS)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_withKeyAttestationRequired_withDisabledClientAttestationRepository_throwsServiceDeactivated() async throws {
    Container.shared.clientAttestationRepository.register { DisabledClientAttestationRepository() }
    generator = HolderBindingsGenerator()

    do {
      _ = try await generator(batchSize: nil, proofTypes: [.Mock.jwtHardwareHigh256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AttestationServiceRepositoryError, .serviceDeactivated)
      XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 0)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
      XCTAssertEqual(credentialKeyRepository.deleteReceivedKeyPair, mockKeyPair)
    }
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
    attestationServiceRepository.fetchKeyAttestationBodyClientAttestationThrowableError = TestingError.error

    do {
      _ = try await generator(batchSize: nil, proofTypes: [.Mock.jwtHardwareHigh256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
      XCTAssertEqual(credentialKeyRepository.deleteReceivedKeyPair, mockKeyPair)
    }
  }

  func testGenerate_keyAttestationInvalid_throwsError() async {
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = false

    do {
      _ = try await generator(batchSize: nil, proofTypes: [.Mock.jwtHardwareHigh256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AttestationServiceRepositoryError, .invalidKeyAttestation)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 1)
      XCTAssertEqual(credentialKeyRepository.deleteReceivedKeyPair, mockKeyPair)
    }
  }

  func testGenerate_credentialKeyPairGeneratorThrowsError_throwsErrorAndLoggs() async {
    credentialKeyRepository.createAlgorithmIsHardwareBoundThrowableError = TestingError.error

    generator = HolderBindingsGenerator()

    do {
      _ = try await generator(batchSize: nil, proofTypes: [.Mock.jwtHardwareHigh256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(analyticsProvider.logCounter, 1)
    }
  }

  func testGenerate_preferredKeyBindingAlgorithmPriorisation_receivesHighesPrioAlgorithm() async throws {
    let proofType = CredentialIssuerMetadata.ProofType.Mock.createJwt(supportedAlgorithms: [.ES256, .ES512])
    let preferredAlgorithms: [JWTAlgorithm] = [.ES512, .ES384, .ES256]
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { preferredAlgorithms }
    generator = HolderBindingsGenerator()

    _ = try await generator(batchSize: nil, proofTypes: [proofType])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.algorithm, JWTAlgorithm.ES512.rawValue)
  }

  func testGenerate_metadataWithEmptyKeyStorage_keyPairGeneratedWithSecureEnclave() async throws {
    let proofType = CredentialIssuerMetadata.ProofType.Mock.createJwt(keyStorageLevels: [])

    _ = try await generator(batchSize: nil, proofTypes: [proofType])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_multipleSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate, .iso18045High] }

    generator = HolderBindingsGenerator()
    let proofType = CredentialIssuerMetadata.ProofType.Mock.createJwt(keyStorageLevels: [.iso18045Moderate, .iso18045High])

    _ = try await generator(batchSize: nil, proofTypes: [proofType])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_mixedSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate] }
    let proofType = CredentialIssuerMetadata.ProofType.Mock.createJwt(keyStorageLevels: [.iso18045Moderate, .iso18045High])
    generator = HolderBindingsGenerator()

    _ = try await generator(batchSize: nil, proofTypes: [proofType])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testGenerate_batchMetadata_generatesMultipleBindings() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 10, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 10)
    XCTAssertEqual(bindings.count, 10)
  }

  func testGenerate_batchMetadataUpperBound_generatesMultipleBindingsAsSpecified() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 100, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 100)
    XCTAssertEqual(bindings.count, 100)
  }

  func testGenerate_batchMetadataOverUpperBound_generatesMultipleBindingsUpToUpperBound() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 101, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 100)
    XCTAssertEqual(bindings.count, 100)
  }

  func testGenerate_batchKeyCreationThrows_deletesKeys() async {
    let firstKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    var createCallCount = 0
    credentialKeyRepository.createAlgorithmIsHardwareBoundClosure = { _, _ in
      createCallCount += 1
      guard createCallCount == 1 else {
        throw TestingError.error
      }
      return firstKeyPair
    }
    Container.shared.isBatchIssuanceEnabled.register { true }
    generator = HolderBindingsGenerator()

    do {
      _ = try await generator(batchSize: 2, proofTypes: [.Mock.jwtSoftware256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 2)
      XCTAssertEqual(credentialKeyRepository.deleteReceivedInvocations, [firstKeyPair])
    }
  }

  func testGenerate_batchMetadata_whenBatchIssuanceDisabled_generatesSingleBinding() async throws {
    Container.shared.isBatchIssuanceEnabled.register { false }
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 10, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundCallsCount, 1)
    XCTAssertEqual(bindings.count, 1)
  }

  func testGenerate_batchMetadataWithZeroBatchSize_returnsEmpty() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 0, proofTypes: [.Mock.jwtSoftware256])

    XCTAssertFalse(credentialKeyRepository.createAlgorithmIsHardwareBoundCalled)
    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 0)
    XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationCallsCount, 0)
    XCTAssertTrue(bindings.isEmpty)
  }

  func testGenerate_batchMetadataWithKeyAttestationRequired_fetchesBatchKeyAttestation() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    generator = HolderBindingsGenerator()

    let bindings = try await generator(batchSize: 2, proofTypes: [.Mock.jwtHardwareHigh256])

    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 0)
    XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationCallsCount, 1)
    XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationReceivedArguments?.body.count, 2)
    XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
    XCTAssertEqual(bindings.count, 2)
    XCTAssertEqual(bindings.map(\.keyAttestationJWS), [mockKeyAttestation.rawJWS, mockKeyAttestation.rawJWS])
  }

  func testGenerate_batchMetadataWithKeyAttestationRequired_whenBatchKeyAttestationCountDoesNotMatch_throwsInvalidKeyAttestation() async {
    Container.shared.isBatchIssuanceEnabled.register { true }
    attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationReturnValue = [mockKeyAttestation]
    generator = HolderBindingsGenerator()

    do {
      _ = try await generator(batchSize: 2, proofTypes: [.Mock.jwtHardwareHigh256])
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AttestationServiceRepositoryError, .invalidKeyAttestation)
      XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationCallsCount, 1)
      XCTAssertEqual(attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationReceivedArguments?.body.count, 2)
      XCTAssertEqual(credentialKeyRepository.deleteCallsCount, 2)
      XCTAssertEqual(credentialKeyRepository.deleteReceivedInvocations, [mockKeyPair, mockKeyPair])
    }
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

  private var attestationServiceRepository = AttestationServiceRepositoryProtocolSpy()
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
    Container.shared.attestationServiceRepository.register { self.attestationServiceRepository }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
    Container.shared.analytics.register { self.analytics }
  }

  private func success() {
    attestationServiceRepository.fetchKeyAttestationBodyClientAttestationReturnValue = mockKeyAttestation
    attestationServiceRepository.fetchBatchKeyAttestationBodyClientAttestationReturnValue = [mockKeyAttestation, mockKeyAttestation]
    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = true
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = mockKeyPair
  }

  private func assertUnsupportedAlgorithmException(for metadataWrapper: CredentialIssuerMetadataWrapper, preferredAlgos: [JWTAlgorithm]) async throws {
    guard let supportedAlgos = metadataWrapper.selectedCredential.proofTypesSupported.first?.algorithms else {
      fatalError("Cannot extract supported algorithms")
    }

    do {
      _ = try await generator(batchSize: nil, proofTypes: [.Mock.jwtSoftware256])
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.unsupportedAlgorithm {
      XCTAssertFalse(supportedAlgos.contains { preferredAlgos.map(\.rawValue).contains($0) })
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    } catch {
      XCTFail("Not the expected error")
    }
  }
}
