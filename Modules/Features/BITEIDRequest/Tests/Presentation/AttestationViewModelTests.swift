import BITAppAuth
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITEIDRequest
@testable import BITLocalAuthentication
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class AttestationViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    router = MockEIDRequestRouter()
    userSession = SessionSpy()
    fetchClientAttestationUseCase = FetchClientAttestationUseCaseProtocolSpy()
    fetchKeyAttestationUseCase = FetchKeyAttestationUseCaseProtocolSpy()
    mockContext = LAContextProtocolSpy()

    Container.shared.userSession.register { self.userSession }
    Container.shared.fetchClientAttestationUseCase.register { self.fetchClientAttestationUseCase }
    Container.shared.fetchKeyAttestationUseCase.register { self.fetchKeyAttestationUseCase }

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

    XCTAssertFalse(fetchClientAttestationUseCase.executeCalled)
    XCTAssertFalse(fetchKeyAttestationUseCase.executeCalled)
    XCTAssertFalse(router.legalRepresentantCalled)
  }

  @MainActor
  func testFetchAttestations_withContext_success() async {
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(fetchClientAttestationUseCase.executeCalled)
    XCTAssertTrue(fetchKeyAttestationUseCase.executeCalled)
    XCTAssertTrue(router.attestationErrorCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 3.0)
  }

  @MainActor
  func testFetchAttestations_clientAttestationFails_continuesFlow() async {
    fetchClientAttestationUseCase.executeThrowableError = EIDRequestRepository.Error.invalidClientAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(fetchClientAttestationUseCase.executeCalled)
    XCTAssertFalse(fetchKeyAttestationUseCase.executeCalled)
    XCTAssertTrue(router.clientAttestationErrorCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 3.0)
  }

  @MainActor
  func testFetchAttestations_keyAttestationFails_continuesFlow() async {
    fetchKeyAttestationUseCase.executeThrowableError = EIDRequestRepository.Error.invalidKeyAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(fetchClientAttestationUseCase.executeCalled)
    XCTAssertTrue(fetchKeyAttestationUseCase.executeCalled)
    XCTAssertTrue(router.keyAttestationErrorCalled)
    XCTAssertGreaterThanOrEqual(elapsedTime, 3.0)
  }

  @MainActor
  func testFetchAttestations_fastExecution_appliesMinimumDelay() async {
    setupFastExecutingUseCases()

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 3.0)
    XCTAssertLessThan(elapsedTime, 3.5, "Should not take significantly longer than minimum delay")
  }

  @MainActor
  func testFetchAttestations_slowExecution_noAdditionalDelay() async {
    setupSlowExecutingUseCases()

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 4.0)
    XCTAssertLessThan(elapsedTime, 4.5, "Should not add delay when execution is already slow")
  }

  @MainActor
  func testFetchAttestations_moderateExecution_minimalAdditionalDelay() async {
    setupModerateExecutingUseCases()

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 3.0)
    XCTAssertLessThan(elapsedTime, 3.5, "Should add minimal delay to reach 3 seconds")
  }

  // MARK: Private

  private var viewModel: AttestationViewModel!
  private var router: MockEIDRequestRouter!
  private var userSession: SessionSpy!
  private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocolSpy!
  private var fetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocolSpy!
  private var mockContext: LAContextProtocolSpy!

  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private let mockKeyAttestation = KeyAttestationPayload.Mock.sample

  private func success() {
    userSession.context = mockContext
    viewModel = AttestationViewModel(router: router)

    fetchClientAttestationUseCase.executeReturnValue = mockClientAttestation
    fetchKeyAttestationUseCase.executeReturnValue = mockKeyAttestation
  }

  // MARK: - Test Setup Helpers

  private func setupFastExecutingUseCases() {
    fetchClientAttestationUseCase.executeReturnValue = mockClientAttestation
    fetchKeyAttestationUseCase.executeReturnValue = mockKeyAttestation
  }

  private func setupSlowExecutingUseCases() {
    // Simulate slow use cases by adding delays
    fetchClientAttestationUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 2_000_000_000)
      return self.mockClientAttestation
    }

    fetchKeyAttestationUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 2_000_000_000)
      return self.mockKeyAttestation
    }
  }

  private func setupModerateExecutingUseCases() {
    // Simulate moderately slow use cases
    fetchClientAttestationUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 1_000_000_000)
      return self.mockClientAttestation
    }

    fetchKeyAttestationUseCase.executeClosure = { _ in
      try await Task.sleep(nanoseconds: 1_000_000_000)
      return self.mockKeyAttestation
    }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
