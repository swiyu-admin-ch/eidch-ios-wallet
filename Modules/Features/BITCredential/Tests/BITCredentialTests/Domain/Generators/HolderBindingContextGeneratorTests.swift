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

final class HolderBindingContextGeneratorTests: XCTestCase {

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

    generator = HolderBindingContextGenerator()
  }

  func testGenerate_metadataWithoutProofTypes_returnsNil() async throws {
    let context = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleWithoutProofTypes)

    XCTAssertFalse(credentialKeyRepository.createAlgorithmIsHardwareBoundCalled)
    XCTAssertNil(context)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_metadataWithProofTypesNoKeyAttestationRequired_returnsValidContext() async throws {
    let softwareBoundKeyPair = VaultKeyPair.Mock.ES256SavePermanently(id: UUID())
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = softwareBoundKeyPair
    generator = HolderBindingContextGenerator()

    let context = try await generator.generate(from: CredentialMetadataWrapper.Mock.sample)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, false)
    XCTAssertEqual(context?.keyPair, softwareBoundKeyPair)
    XCTAssertNil(context?.keyAttestationJWS)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_metadataWithKeyAttestationRequired_returnsValidContext() async throws {
    let context = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleKeyAttestationRequired)

    XCTAssertEqual(fetchKeyAttestationUseCase.executeForReceivedArguments?.keyPair, mockKeyPair)
    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
    XCTAssertEqual(context?.keyPair, mockKeyPair)
    XCTAssertEqual(context?.keyAttestationJWS, mockKeyAttestation.rawJWS)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testGenerate_incorrectPreferredAlgorithms_throwsUnsupportedAlgorithm() async throws {
    let mockPreferredAlgos = [JWTAlgorithm.ES384]
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { mockPreferredAlgos }

    generator = HolderBindingContextGenerator()

    try await assertUnsupportedAlgorithmException(for: mockMetadataWrapper, preferredAlgos: mockPreferredAlgos)
  }

  func testGenerate_noMatchablePreferredAlgorithms_throwsUnsupportedAlgorithm() async throws {
    let mockPreferredAlgos = [JWTAlgorithm]()
    Container.shared.preferredKeyBindingAlgorithmsOrdered.register { mockPreferredAlgos }

    generator = HolderBindingContextGenerator()

    try await assertUnsupportedAlgorithmException(for: mockMetadataWrapper, preferredAlgos: mockPreferredAlgos)
  }

  func testGenerate_keyAttestationUseCaseThrowsError_throwsError() async {
    fetchKeyAttestationUseCase.executeForThrowableError = TestingError.error

    do {
      _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleKeyAttestationRequired)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_credentialKeyPairGeneratorThrowsError_throwsErrorAndLoggs() async {
    credentialKeyRepository.createAlgorithmIsHardwareBoundThrowableError = TestingError.error

    generator = HolderBindingContextGenerator()

    do {
      _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleKeyAttestationRequired)
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

    generator = HolderBindingContextGenerator()

    _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleKeyAttestationRequired)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.algorithm, JWTAlgorithm.ES512.rawValue)
    XCTAssertTrue(supportedAlgos.contains { self.mockpreferredKeyBindingAlgorithmsOrdered.map(\.rawValue).contains($0) })
  }

  func testGenerate_metadataWithEmptyKeyStorage_keyPairGeneratedWithSecureEnclave() async throws {
    _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleEmptyKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_multipleSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate, .iso18045High] }

    generator = HolderBindingContextGenerator()

    _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleMultipleKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  func testExecute_mixedSupportedKeyStorages_keyPairGeneratedWithSecureEnclave() async throws {
    Container.shared.supportedKeyStorageSecurityLevel.register { [.iso18045Moderate] }

    generator = HolderBindingContextGenerator()

    _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sampleMultipleKeyStorage)

    XCTAssertEqual(credentialKeyRepository.createAlgorithmIsHardwareBoundReceivedArguments?.isHardwareBound, true)
  }

  // MARK: Private

  private var generator = HolderBindingContextGenerator()

  private var mockContext = LAContextProtocolSpy()
  private let mockMetadataWrapper = CredentialMetadataWrapper.Mock.sample
  private let mockpreferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm] = [.ES256]
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockSupportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel] = [.iso18045High]
  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample

  private var fetchKeyAttestationUseCase = FetchKeyAttestationUseCaseProtocolSpy()
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
    Container.shared.fetchKeyAttestationUseCase.register { self.fetchKeyAttestationUseCase }
    Container.shared.analytics.register { self.analytics }
  }

  private func success() {
    fetchKeyAttestationUseCase.executeForReturnValue = mockKeyAttestation
    credentialKeyRepository.createAlgorithmIsHardwareBoundReturnValue = mockKeyPair
  }

  private func assertUnsupportedAlgorithmException(for metadataWrapper: CredentialMetadataWrapper, preferredAlgos: [JWTAlgorithm]) async throws {
    guard let supportedAlgos = metadataWrapper.selectedCredential.proofTypesSupported.first?.algorithms else {
      fatalError("Cannot extract supported algorithms")
    }

    do {
      _ = try await generator.generate(from: CredentialMetadataWrapper.Mock.sample)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.unsupportedAlgorithm {
      XCTAssertFalse(supportedAlgos.contains { preferredAlgos.map(\.rawValue).contains($0) })
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    } catch {
      XCTFail("Not the expected error")
    }
  }
}
