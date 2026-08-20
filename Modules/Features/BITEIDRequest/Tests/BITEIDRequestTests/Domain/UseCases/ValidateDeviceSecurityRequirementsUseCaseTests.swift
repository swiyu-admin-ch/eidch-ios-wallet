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

final class ValidateDeviceSecurityRequirementsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    setupMocks()
    success()
  }

  func testCallAsFunction_success_callsCount() async throws {
    try await useCase(userContext)

    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationCallsCount, 1)
    XCTAssertEqual(keyAttestationValidator.callAsFunctionKeyPairWithCallsCount, 1)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationCallsCount, 1)
  }

  func testCallAsFunction_success_receivedArguments() async throws {
    try await useCase(userContext)

    XCTAssertEqual(appAttestationKeyRepository.createForWithReceivedArguments?.context.localizedReason, mockReason)
    XCTAssertEqual(attestationServiceRepository.fetchKeyAttestationBodyClientAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
    XCTAssertEqual(keyAttestationValidator.callAsFunctionKeyPairWithReceivedArguments?.keyPair, mockKeyPair)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationReceivedArguments?.keyAttestation, mockKeyAttestation)
    XCTAssertEqual(validateAttestationsUseCase.executeClientAttestationKeyAttestationReceivedArguments?.clientAttestation, mockClientAttestation)
  }

  func testCallAsFunction_clientAttestationThrows_throws() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_invalidClientAttestation_throws() async throws {
    clientAttestationRepository.getUsingThrowableError = AttestationServiceRepositoryError.invalidClientAttestation

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? SIDRepository.Error, .invalidClientAttestation)
    }
  }

  func testCallAsFunction_clientAttestationThrowsNetworkError_throws() async throws {
    clientAttestationRepository.getUsingThrowableError = NetworkError(status: .badRequest)

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? ValidateDeviceSecurityRequirementsUseCaseError, .networkError)
    }
  }

  func testCallAsFunction_clientAttestationThrowsTimeout_throwsAttestationTimeout() async throws {
    clientAttestationRepository.getUsingThrowableError = AttestationServiceRepositoryError.timeout

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? ValidateDeviceSecurityRequirementsUseCaseError, .attestationTimeout)
    }
  }

  func testCallAsFunction_withDisabledClientAttestationRepository_throwsAttestationServiceDeactivated() async throws {
    Container.shared.clientAttestationRepository.register { DisabledClientAttestationRepository() }
    useCase = ValidateDeviceSecurityRequirementsUseCase()

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? ValidateDeviceSecurityRequirementsUseCaseError, .attestationServiceDeactivated)
    }
  }

  func testCallAsFunction_keyRepositoryThrows_throws() async throws {
    appAttestationKeyRepository.createForWithThrowableError = TestingError.error

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_keyAttestationThrows_throws() async throws {
    attestationServiceRepository.fetchKeyAttestationBodyClientAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_keyAttestationThrowsServiceDeactivated_throwsAttestationServiceDeactivated() async throws {
    attestationServiceRepository.fetchKeyAttestationBodyClientAttestationThrowableError =
      AttestationServiceRepositoryError.serviceDeactivated

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? ValidateDeviceSecurityRequirementsUseCaseError, .attestationServiceDeactivated)
    }
  }

  func testCallAsFunction_validateThrows_throws() async throws {
    validateAttestationsUseCase.executeClientAttestationKeyAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_invalidKeyAttestation_throws() async throws {
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = false

    do {
      _ = try await useCase(userContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? SIDRepository.Error, .invalidKeyAttestation)
    }
  }

  // MARK: Private

  private var useCase = ValidateDeviceSecurityRequirementsUseCase()

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockReason = "mockReason"

  private var clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
  private var attestationServiceRepository = AttestationServiceRepositoryProtocolSpy()
  private var validateAttestationsUseCase = ValidateAttestationsUseCaseProtocolSpy()
  private var appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
  private var keyAttestationValidator = KeyAttestationValidatorProtocolSpy()
  private var userContext = LAContextProtocolSpy()

  private func setupMocks() {
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.attestationServiceRepository.register { self.attestationServiceRepository }
    Container.shared.validateAttestationsUseCase.register { self.validateAttestationsUseCase }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.keyAttestationValidator.register { self.keyAttestationValidator }
  }

  private func success() {
    userContext = LAContextProtocolSpy()
    userContext.localizedReason = mockReason
    useCase = ValidateDeviceSecurityRequirementsUseCase()

    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    attestationServiceRepository.fetchKeyAttestationBodyClientAttestationReturnValue = mockKeyAttestation
    appAttestationKeyRepository.createForWithReturnValue = mockKeyPair
    keyAttestationValidator.callAsFunctionKeyPairWithReturnValue = true
  }

}

// swiftlint:enable implicitly_unwrapped_optional
