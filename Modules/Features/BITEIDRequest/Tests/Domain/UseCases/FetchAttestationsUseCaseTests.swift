@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITEIDRequest
@testable import BITLocalAuthentication
@testable import BITNetworking
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest

final class FetchAttestationsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    setupMocks()
    success()
  }

  func testExecute_success_callsCount() async throws {
    try await useCase.execute(userContext)

    XCTAssertEqual(fetchClientAttestationUseCase.executeCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
    XCTAssertEqual(fetchKeyAttestationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationCallsCount, 1)
  }

  func testExecute_success_receivedArguments() async throws {
    try await useCase.execute(userContext)

    XCTAssertEqual(fetchClientAttestationUseCase.executeReceivedContext?.localizedReason, mockReason)
    XCTAssertEqual(appAttestationKeyRepository.createForWithReceivedArguments?.context.localizedReason, mockReason)
    XCTAssertEqual(fetchKeyAttestationUseCase.executeForReceivedArguments?.context.localizedReason, mockReason)
    XCTAssertEqual(fetchKeyAttestationUseCase.executeForReceivedArguments?.keyPair, mockKeyPair)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationReceivedArguments?.keyAttestation, mockKeyAttestation)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
  }

  func testExecute_clientAttestationThrows_throws() async throws {
    fetchClientAttestationUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_clientAttestationThrowsNetworkError_throws() async throws {
    fetchClientAttestationUseCase.executeThrowableError = NetworkError(status: .badRequest)

    do {
      _ = try await useCase.execute(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAttestationsUseCaseError, .networkError)
    }
  }

  func testExecute_keyRepositoryThrows_throws() async throws {
    appAttestationKeyRepository.createForWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_keyAttestationThrows_throws() async throws {
    fetchKeyAttestationUseCase.executeForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validateThrows_throws() async throws {
    validateAttestationsUseCase.executeClientAttestationKeyAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase = FetchAttestationsUseCase()

  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private let mockKeyAttestation = KeyAttestationPayload.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockReason = "mockReason"

  private var fetchClientAttestationUseCase = FetchClientAttestationUseCaseProtocolSpy()
  private var fetchKeyAttestationUseCase = FetchKeyAttestationUseCaseProtocolSpy()
  private var validateAttestationsUseCase = ValidateAttestationsUseCaseProtocolSpy()
  private var appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
  private var userContext = LAContextProtocolSpy()

  private func setupMocks() {
    Container.shared.fetchClientAttestationUseCase.register { self.fetchClientAttestationUseCase }
    Container.shared.fetchKeyAttestationUseCase.register { self.fetchKeyAttestationUseCase }
    Container.shared.validateAttestationsUseCase.register { self.validateAttestationsUseCase }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
  }

  private func success() {
    userContext = LAContextProtocolSpy()
    userContext.localizedReason = mockReason
    useCase = FetchAttestationsUseCase()

    fetchClientAttestationUseCase.executeReturnValue = mockClientAttestation
    fetchKeyAttestationUseCase.executeForReturnValue = mockKeyAttestation
    appAttestationKeyRepository.createForWithReturnValue = mockKeyPair
  }

}

// swiftlint:enable implicitly_unwrapped_optional
