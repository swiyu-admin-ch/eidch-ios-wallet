// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try force_cast
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCore
@testable import BITTestingCore

final class GenerateClientAttestedRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = GenerateClientAttestedRequestUseCase()
    createSuccessState()
  }

  func testGenerate_parameters_success() async throws {
    let result = try await useCase.execute(for: mockBody, challenge: mockChallenge.challenge, audience: mockAudience)

    XCTAssertEqual(result.body as! GenerateClientAttestedRequestUseCaseTests.MockBody, mockBody)
    XCTAssertEqual(result.header.clientAttestation, mockClientAttestation.rawJWS)
    XCTAssertEqual(result.header.clientAttestationPoP, mockClientAttestationPop.rawJWS)

    XCTAssertTrue(clientAttestationRepository.getClientAttestationCalled)
    XCTAssertEqual(appAttestationKeyRepository.getAttestionKeyForReceivedAttestKey, .clientAttestation)
    XCTAssertEqual(generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyReceivedArguments?.body as? GenerateClientAttestedRequestUseCaseTests.MockBody, mockBody)
    XCTAssertEqual(generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyReceivedArguments?.challenge, mockChallenge.challenge)
    XCTAssertEqual(generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyReceivedArguments?.clientAttestation, mockClientAttestation)
    XCTAssertEqual(generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyReceivedArguments?.audience, mockAudience)
  }

  func testGenerate_count_success() async throws {
    _ = try await useCase.execute(for: mockBody, challenge: mockChallenge.challenge, audience: mockAudience)

    XCTAssertEqual(clientAttestationRepository.getClientAttestationCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.getAttestionKeyForCallsCount, 1)
    XCTAssertEqual(generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyCallsCount, 1)
  }

  func testGenerate_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getClientAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockBody, challenge: mockChallenge.challenge, audience: mockAudience)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_getAttestedKeyFails_throwsError() async throws {
    appAttestationKeyRepository.getAttestionKeyForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockBody, challenge: mockChallenge.challenge, audience: mockAudience)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_generateProofOfPossessionFails_throwsError() async throws {
    generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockBody, challenge: mockChallenge.challenge, audience: mockAudience)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private struct MockBody: Encodable, Equatable {
    let mock = "mock"
  }

  private var useCase: GenerateClientAttestedRequestUseCase!

  private let mockAudience = "mock_audience"
  private let mockBody = MockBody()
  private let mockChallenge = AttestationChallenge.Response.Mock.sample
  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private let mockClientAttestationPop = ClientAttestationProofOfPossession.Mock.sample
  private let mockSecKey = SecKeyTestsHelper.createPrivateKey(size: 256)

  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var generateProofOfPossessionUseCase: GenerateProofOfPossessionUseCaseProtocolSpy!

  private func createSuccessState() {
    clientAttestationRepository.getClientAttestationReturnValue = mockClientAttestation
    appAttestationKeyRepository.getAttestionKeyForReturnValue = mockSecKey
    generateProofOfPossessionUseCase.executeForChallengeAudienceBodySigningKeyReturnValue = mockClientAttestationPop
  }

  private func registerMocks() {
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    generateProofOfPossessionUseCase = GenerateProofOfPossessionUseCaseProtocolSpy()

    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.generateProofOfPossessionUseCase.register { self.generateProofOfPossessionUseCase }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping force_try force_cast
