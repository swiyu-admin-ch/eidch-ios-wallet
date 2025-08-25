import BITAppAuth
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITEIDRequest
@testable import BITLocalAuthentication
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class ValidateAttestationsViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    router = MockEIDRequestRouter()
    userSession = SessionSpy()
    fetchAttestationsUseCase = FetchAttestationsUseCaseProtocolSpy()
    mockContext = LAContextProtocolSpy()

    Container.shared.userSession.register { self.userSession }
    Container.shared.fetchAttestationsUseCase.register { self.fetchAttestationsUseCase }

    success()
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testFetchAttestations_noContext_returnsEarly() async {
    userSession.context = nil

    await viewModel.fetchAttestations()

    XCTAssertFalse(fetchAttestationsUseCase.executeCalled)
    XCTAssertFalse(router.legalRepresentantCalled)
    XCTAssertEqual(router.attestationError as! UserSessionError, .notLoggedIn)
  }

  @MainActor
  func testFetchAttestations_withContext_success() async {
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(fetchAttestationsUseCase.executeCalled)
    XCTAssertTrue(router.legalRepresentantCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_clientAttestationFails_continuesFlow() async {
    fetchAttestationsUseCase.executeThrowableError = EIDRequestRepository.Error.invalidClientAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(router.clientAttestationErrorCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_keyAttestationFails_continuesFlow() async {
    fetchAttestationsUseCase.executeThrowableError = EIDRequestRepository.Error.invalidKeyAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(router.keyAttestationErrorCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_fastExecution_appliesMinimumDelay() async {
    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertLessThan(elapsedTime, 2.5, "Should not take significantly longer than minimum delay")
  }

  @MainActor
  func testFetchAttestations_slowExecution_noAdditionalDelay() async {
    fetchAttestationsUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 2_000_000_000)
    }

    viewModel = ValidateAttestationsViewModel(router: router)

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertLessThan(elapsedTime, 4.5, "Should not add delay when execution is already slow")
  }

  @MainActor
  func testFetchAttestations_moderateExecution_minimalAdditionalDelay() async {
    fetchAttestationsUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    viewModel = ValidateAttestationsViewModel(router: router)

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertLessThan(elapsedTime, 2.5, "Should add minimal delay to reach 3 seconds")
  }

  // MARK: Private

  private var viewModel: ValidateAttestationsViewModel!
  private var router: MockEIDRequestRouter!
  private var userSession: SessionSpy!
  private var fetchAttestationsUseCase: FetchAttestationsUseCaseProtocolSpy!
  private var mockContext: LAContextProtocolSpy!

  private func success() {
    userSession.context = mockContext
    viewModel = ValidateAttestationsViewModel(router: router)
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_cast
