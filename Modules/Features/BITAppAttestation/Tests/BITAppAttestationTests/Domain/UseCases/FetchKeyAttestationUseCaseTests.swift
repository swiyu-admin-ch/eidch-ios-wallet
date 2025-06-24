// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITTestingCore

final class FetchKeyAttestationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = FetchKeyAttestationUseCase()
    createSuccessState()
  }

  func testExecute_parameters_success() async throws {
    let result = try await useCase.execute(context)

    XCTAssertEqual(result.payload, mockKeyAttestation.payload)

    XCTAssertEqual(appAttestationKeyRepository.createAttestationKeyForWithReceivedArguments?.attestKey, .keyAttestation)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.body as? KeyAttestationRequestBody, mockKeyAttestationRequestBody)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.challenge, mockChallengeResponse.challenge)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.audience, mockClientAttestation.payload.issuer)
    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationWithReceivedRequest?.body as? KeyAttestationRequestBody, mockKeyAttestationRequestBody)
    XCTAssertEqual(keyAttestationValidator.validateReceivedKeyAttestation?.payload, mockKeyAttestation.payload)
  }

  func testExecute_count_success() async throws {
    _ = try await useCase.execute(context)

    XCTAssertEqual(appAttestationKeyRepository.createAttestationKeyForWithCallsCount, 1)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceCallsCount, 1)
    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationWithCallsCount, 1)
    XCTAssertEqual(keyAttestationValidator.validateCallsCount, 1)
  }

  func testExecute_fetchChallengeFails_throwsError() async throws {
    appAttestationRepository.fetchChallengeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_createAttestationKeyFails_throwsError() async throws {
    appAttestationKeyRepository.createAttestationKeyForWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_generateClientAttestedRequestFails_throwsError() async throws {
    generateClientAttestedRequestUseCase.executeForChallengeAudienceThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchKeyAttestationFails_throwsError() async throws {
    appAttestationRepository.fetchKeyAttestationWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validateKeyAttestationReturnsFalse_throwsError() async throws {
    keyAttestationValidator.validateReturnValue = false

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? FetchKeyAttestationUseCase.Error, .invalidKeyAttestation)
    }
  }

  func testExecute_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getClientAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: FetchKeyAttestationUseCase!

  private var context: LAContextProtocolSpy!
  private var mockClientAttestedRequest: ClientAttestedRequest!
  private var appAttestationRepository: AppAttestationRepositoryProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var keyAttestationValidator: KeyAttestationValidatorProtocolSpy!
  private var generateClientAttestedRequestUseCase: GenerateClientAttestedRequestUseCaseProtocolSpy!
  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!

  private var mockKeyAttestationRequestBody: KeyAttestationRequestBody!
  private let mockSecKey = SecKeyTestsHelper.createPrivateKey(size: 256)
  private let mockKeyAttestation = KeyAttestationPayload.Mock.sample
  private var mockChallengeResponse = AttestationChallenge.Response.Mock.sample
  private var mockClientAttestation = ClientAttestationPayload.Mock.sample

  private func createSuccessState() {
    appAttestationRepository.fetchKeyAttestationWithReturnValue = mockKeyAttestation
    appAttestationKeyRepository.createAttestationKeyForWithReturnValue = mockSecKey
    generateClientAttestedRequestUseCase.executeForChallengeAudienceReturnValue = mockClientAttestedRequest
    keyAttestationValidator.validateReturnValue = true
    appAttestationRepository.fetchChallengeReturnValue = mockChallengeResponse.challenge
    clientAttestationRepository.getClientAttestationReturnValue = mockClientAttestation
  }

  private func registerMocks() {
    context = LAContextProtocolSpy()
    mockKeyAttestationRequestBody = try! KeyAttestationRequestBody(bindingKey: BindingKey(jwk: JWK(from: KeyPair(privateKey: mockSecKey).publicKey!)))
    appAttestationRepository = AppAttestationRepositoryProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    keyAttestationValidator = KeyAttestationValidatorProtocolSpy()
    generateClientAttestedRequestUseCase = GenerateClientAttestedRequestUseCaseProtocolSpy()
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    mockClientAttestedRequest = ClientAttestedRequest(
      body: mockKeyAttestationRequestBody,
      header: ClientAttestedRequest.Header(clientAttestation: "clientAttestation", clientAttestationPoP: "clientAttestationPoP"))

    Container.shared.appAttestationRepository.register { self.appAttestationRepository }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
    Container.shared.generateClientAttestedRequestUseCase.register { self.generateClientAttestedRequestUseCase }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping force_try
