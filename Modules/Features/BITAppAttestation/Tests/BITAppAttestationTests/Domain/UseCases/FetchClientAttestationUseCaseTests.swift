import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class FetchClientAttestationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = FetchClientAttestationUseCase()
    createSuccessState()
  }

  func testExecute_parameters_success() async throws {
    let result = try await useCase.execute(context)

    XCTAssertEqual(result, mockClientAttestation)

    XCTAssertEqual(appAttestationService.generateAttestedKeyWithReceivedChallenge, mockChallengeResponse.challenge)

    XCTAssertEqual(appAttestationService.generateAppAssertionForWithReceivedArguments?.key, mockAttestedKey.identifier)
    XCTAssertEqual(appAttestationService.generateAppAssertionForWithReceivedArguments?.clientDataObject.challenge, mockClientDataObject.challenge)

    XCTAssertEqual(appAttestationRepository.fetchClientAttestationReceivedRequestBody?.appAssertion, mockAppAssertion.base64EncodedString())
    XCTAssertEqual(appAttestationRepository.fetchClientAttestationReceivedRequestBody?.appAttestation, mockAttestedKey.clientData.base64EncodedString())

    XCTAssertEqual(clientAttestationValidator.validateReceivedClientAttestation?.rawJWS, mockClientAttestationResponse.clientAttestation)
    XCTAssertEqual(clientAttestationRepository.createReceivedClientAttestation?.rawJWS, mockClientAttestationResponse.clientAttestation)
  }

  func testExecute_count_success() async throws {
    _ = try await useCase.execute(context)

    XCTAssertEqual(appAttestationRepository.fetchChallengeCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)

    XCTAssertEqual(appAttestationService.generateAttestedKeyWithCallsCount, 1)
    XCTAssertEqual(appAttestationService.generateAppAssertionForWithCallsCount, 1)

    XCTAssertEqual(clientAttestationValidator.validateCallsCount, 1)
    XCTAssertEqual(clientAttestationRepository.createCallsCount, 1)
  }

  func testExecute_cached_returnsCached() async throws {
    Container.shared.currentDate.register { Date(timeIntervalSince1970: 123456789) }
    clientAttestationRepository.getThrowableError = nil
    clientAttestationRepository.getReturnValue = mockClientAttestation

    let attestation = try await useCase.execute(context)

    XCTAssertEqual(attestation, mockClientAttestation)

    XCTAssertFalse(appAttestationRepository.fetchChallengeCalled)
    XCTAssertFalse(appAttestationKeyRepository.createForWithCalled)

    XCTAssertFalse(appAttestationService.generateAttestedKeyWithCalled)
    XCTAssertFalse(appAttestationService.generateAppAssertionForWithCalled)

    XCTAssertFalse(clientAttestationValidator.validateCalled)
    XCTAssertFalse(clientAttestationRepository.createCalled)
  }

  func testExecute_fetchChallengeFails_throws() async throws {
    appAttestationRepository.fetchChallengeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_generateAttestedKeyFails_throws() async throws {
    appAttestationService.generateAttestedKeyWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_createClientAttestationKeyFails_throws() async throws {
    appAttestationKeyRepository.createForWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_generateAppAssertionFails_throws() async throws {
    appAttestationService.generateAppAssertionForWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchClientAttestationFails_throws() async throws {
    appAttestationRepository.fetchClientAttestationThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validateClientAttestationReturnsFalse_throws() async throws {
    clientAttestationValidator.validateReturnValue = false

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? FetchClientAttestationUseCase.Error, .invalidClientAttestation)
    }
  }

  func testExecute_saveClientAttestationFails_throws() async throws {
    clientAttestationRepository.createThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_cachedClientAttestationIsExpired_retry() async throws {
    clientAttestationRepository.getThrowableError = nil
    clientAttestationRepository.getReturnValue = mockClientAttestation

    _ = try await useCase.execute(context)

    XCTAssertEqual(clientAttestationRepository.deleteCallsCount, 1)
    XCTAssertEqual(appAttestationRepository.fetchChallengeCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
    XCTAssertEqual(appAttestationService.generateAttestedKeyWithCallsCount, 1)
    XCTAssertEqual(appAttestationService.generateAppAssertionForWithCallsCount, 1)
    XCTAssertEqual(clientAttestationRepository.createCallsCount, 1)
  }

  // MARK: Private

  private var context: LAContextProtocolSpy!
  private var useCase: FetchClientAttestationUseCase!
  private var appAttestationService: AppAttestationServiceProtocolSpy!
  private var appAttestationRepository: AppAttestationRepositoryProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var clientAttestationValidator: ClientAttestationValidatorProtocolSpy!
  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!

  private let mockAppAssertion = Data()
  private let mockAttestedKey = AppAttestedKey.Mock.sample
  private let mockChallengeResponse = AttestationChallenge.Response.Mock.sample
  private let mockClientDataObject = ClientDataObject.Mock.sample
  private let mockClientAttestationResponse = ClientAttestationResponse.Mock.sample
  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private func createSuccessState() {
    appAttestationRepository.fetchChallengeReturnValue = mockChallengeResponse.challenge
    appAttestationRepository.fetchClientAttestationReturnValue = mockClientAttestation
    appAttestationService.generateAttestedKeyWithReturnValue = mockAttestedKey
    appAttestationService.generateAppAssertionForWithReturnValue = mockAppAssertion
    appAttestationKeyRepository.createForWithReturnValue = mockKeyPair
    clientAttestationValidator.validateReturnValue = true
    clientAttestationRepository.createReturnValue = mockClientAttestation
    clientAttestationRepository.getThrowableError = ClientAttestationRepositoryError.notFound
  }

  private func registerMocks() {
    context = LAContextProtocolSpy()
    appAttestationService = AppAttestationServiceProtocolSpy()
    appAttestationRepository = AppAttestationRepositoryProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    clientAttestationValidator = ClientAttestationValidatorProtocolSpy()
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()

    Container.shared.appAttestationService.register { self.appAttestationService }
    Container.shared.appAttestationRepository.register { self.appAttestationRepository }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.clientAttestationValidator.register { self.clientAttestationValidator }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.currentDate.register { self.mockClientAttestation.payload.expiredAt!.addingTimeInterval(100) }
  }

}
