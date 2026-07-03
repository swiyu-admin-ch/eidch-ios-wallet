import BITAppAuth
import Factory
import Foundation
import NavigatorUI
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITL10n
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class SetupViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    userSession = SessionSpy()
    validateDeviceSecurityRequirementsUseCase = ValidateDeviceSecurityRequirementsUseCaseProtocolSpy()
    mockContext = LAContextProtocolSpy()

    avBeam = AVBeamProtocolSpy()
    avBeam.state = .initialized
    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.avBeamAppID.register { @MainActor in self.appId }

    Container.shared.userSession.register { @MainActor in self.userSession }
    Container.shared.validateDeviceSecurityRequirementsUseCase.register { @MainActor in self.validateDeviceSecurityRequirementsUseCase }

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

    XCTAssertFalse(validateDeviceSecurityRequirementsUseCase.callAsFunctionCalled)

    if case .setupSDKError = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected legalRepresentantConsentState case")
    }
  }

  @MainActor
  func testFetchAttestations_withContext_success() async {
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertTrue(validateDeviceSecurityRequirementsUseCase.callAsFunctionCalled)
    XCTAssertEqual(viewModel.destination, .legalRepresentant)
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  @MainActor
  func testFetchAttestations_clientAttestationFails_continuesFlow() async {
    validateDeviceSecurityRequirementsUseCase.callAsFunctionThrowableError = EIDRequestRepository.Error.invalidClientAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertEqual(viewModel.destination, .error(.Setup.clientAttestation))
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_keyAttestationFails_continuesFlow() async {
    validateDeviceSecurityRequirementsUseCase.callAsFunctionThrowableError = EIDRequestRepository.Error.invalidKeyAttestation
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertEqual(viewModel.destination, .error(.Setup.keyAttestation))
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_attestationTimeout_displaysErrorView() async {
    validateDeviceSecurityRequirementsUseCase.callAsFunctionThrowableError =
      ValidateDeviceSecurityRequirementsUseCaseError.attestationTimeout
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    guard case .error(let dataset) = viewModel.destination else {
      return XCTFail("Expected attestation service error destination")
    }
    XCTAssertEqual(dataset, .Setup.attestationServiceError)
    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
  }

  @MainActor
  func testFetchAttestations_attestationServiceDeactivated_displaysErrorView() async {
    validateDeviceSecurityRequirementsUseCase.callAsFunctionThrowableError =
      ValidateDeviceSecurityRequirementsUseCaseError.attestationServiceDeactivated
    let startTime = Date()

    await viewModel.fetchAttestations()

    let elapsedTime = Date().timeIntervalSince(startTime)

    guard case .error(let dataset) = viewModel.destination else {
      return XCTFail("Expected attestation service error destination")
    }
    XCTAssertEqual(dataset, .Setup.attestationServiceError)
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
    validateDeviceSecurityRequirementsUseCase.callAsFunctionClosure = { _ in
      try await Task.sleep(nanoseconds: 2_000_000_000)
    }

    viewModel = SetupViewModel()

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertLessThan(elapsedTime, 4.5, "Should not add delay when execution is already slow")
  }

  @MainActor
  func testFetchAttestations_moderateExecution_minimalAdditionalDelay() async {
    validateDeviceSecurityRequirementsUseCase.callAsFunctionClosure = { _ in
      try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    viewModel = SetupViewModel()

    let startTime = Date()
    await viewModel.fetchAttestations()
    let elapsedTime = Date().timeIntervalSince(startTime)

    XCTAssertGreaterThanOrEqual(elapsedTime, 2.0)
    XCTAssertLessThan(elapsedTime, 2.5, "Should add minimal delay to reach 3 seconds")
  }

  @MainActor
  func testCancelInitialization_sdkIsStopped() {
    viewModel.cancelInitialization(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(avBeam.shutdownCallsCount, 1)
  }

  // MARK: Private

  private var viewModel: SetupViewModel!
  private var userSession: SessionSpy!
  private var validateDeviceSecurityRequirementsUseCase: ValidateDeviceSecurityRequirementsUseCaseProtocolSpy!
  private var mockContext: LAContextProtocolSpy!
  private var avBeam: AVBeamProtocolSpy!
  private let appId = "test-app-id"

  @MainActor
  private func success() {
    userSession.context = mockContext
    viewModel = SetupViewModel()
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_cast
