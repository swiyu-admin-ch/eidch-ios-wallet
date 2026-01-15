import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try

final class FetchKeyAttestationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = FetchKeyAttestationUseCase()
    createSuccessState()
  }

  func testExecute_receivedArguments() async throws {
    let result = try await useCase.execute(for: mockKeyPair, context)

    XCTAssertEqual(result.payload, mockKeyAttestation.payload)

    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationReceivedArguments?.body, mockKeyAttestationRequestBody)
    XCTAssertEqual(keyAttestationValidator.validateKeyPairWithReceivedArguments?.keyAttestation.payload, mockKeyAttestation.payload)
  }

  func testExecute_count_success() async throws {
    _ = try await useCase.execute(for: mockKeyPair, context)

    XCTAssertEqual(fetchClientAttestationUseCase.executeCallsCount, 1)
    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 1)
    XCTAssertEqual(keyAttestationValidator.validateKeyPairWithCallsCount, 1)
  }

  func testExecute_fetchClientAttestationFails_throwsError() async throws {
    fetchClientAttestationUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockKeyPair, context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }

    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 0)
    XCTAssertEqual(keyAttestationValidator.validateKeyPairWithCallsCount, 0)
  }

  func testExecute_fetchKeyAttestationFails_throwsError() async throws {
    appAttestationRepository.fetchKeyAttestationBodyClientAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockKeyPair, context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }

    XCTAssertEqual(appAttestationRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 1)
    XCTAssertEqual(keyAttestationValidator.validateKeyPairWithCallsCount, 0)
  }

  func testExecute_validateKeyAttestationReturnsFalse_throwsError() async throws {
    keyAttestationValidator.validateKeyPairWithReturnValue = false

    do {
      _ = try await useCase.execute(for: mockKeyPair, context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? FetchKeyAttestationUseCase.Error, .invalidKeyAttestation)
    }
  }

  // MARK: Private

  private var useCase: FetchKeyAttestationUseCase!

  private var context: LAContextProtocolSpy!
  private var appAttestationRepository: AppAttestationRepositoryProtocolSpy!
  private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocolSpy!
  private var keyAttestationValidator: KeyAttestationValidatorProtocolSpy!

  private var mockKeyAttestationRequestBody: KeyAttestationRequestBody!
  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample
  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private func createSuccessState() {
    keyAttestationValidator.validateKeyPairWithReturnValue = true
    appAttestationRepository.fetchKeyAttestationBodyClientAttestationReturnValue = mockKeyAttestation
    fetchClientAttestationUseCase.executeReturnValue = mockClientAttestation
  }

  private func registerMocks() {
    context = LAContextProtocolSpy()
    mockKeyAttestationRequestBody = try! KeyAttestationRequestBody(bindingKey: BindingKey(jwk: JWK(from: mockKeyPair.publicKey!)))
    appAttestationRepository = AppAttestationRepositoryProtocolSpy()
    fetchClientAttestationUseCase = FetchClientAttestationUseCaseProtocolSpy()
    keyAttestationValidator = KeyAttestationValidatorProtocolSpy()

    Container.shared.appAttestationRepository.register { self.appAttestationRepository }
    Container.shared.fetchClientAttestationUseCase.register { self.fetchClientAttestationUseCase }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping force_try
