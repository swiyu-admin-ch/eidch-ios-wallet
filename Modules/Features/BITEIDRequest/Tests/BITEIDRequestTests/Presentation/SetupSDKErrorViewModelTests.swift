import BITL10n
import DeviceCheck
import XCTest
@testable import BITEIDRequest

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate

@MainActor
class SetupSDKErrorViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    mockError = ErrorWrapper(NSError())

    viewModel = SetupSDKErrorViewModel(error: mockError, callback: { _ in })
  }

  func testInitialState_insufficientKeyStorageResistanceError() {
    let error = ErrorWrapper(SIDRepository.Error.insufficientKeyStorageResistance)
    viewModel = SetupSDKErrorViewModel(error: error, callback: { _ in })

    XCTAssertFalse(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationInsufficientKeyStorageTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationInsufficientKeyStorageBody)
  }

  func testInitialState_DCErrorTimeoutError() {
    let error = ErrorWrapper(DCError(.serverUnavailable))
    viewModel = SetupSDKErrorViewModel(error: error, callback: { _ in })

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationDeviceCheckTimeoutTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationDeviceCheckTimeoutBody)
  }

  func testInitialState_DCError() {
    let error = ErrorWrapper(DCError(.invalidInput))
    viewModel = SetupSDKErrorViewModel(error: error, callback: { _ in })

    XCTAssertFalse(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationDeviceCheckErrorTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationDeviceCheckErrorBody)
  }

  func testInitialState_unknownError() {
    let error = ErrorWrapper(ValidateDeviceSecurityRequirementsUseCaseError.networkError)
    viewModel = SetupSDKErrorViewModel(error: error, callback: { _ in })

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationServiceErrorTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationServiceErrorBody)
  }

  func testInitialState_unhandledError() {
    viewModel = SetupSDKErrorViewModel(error: mockError, callback: { _ in })

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestAttestationUnknownErrorPrimary)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestAttestationUnknownErrorSecondary)
  }

  func testPrimaryAction() {
    viewModel.primaryAction()

    XCTAssertTrue(viewModel.isNavigationBackTriggered)
  }

  // MARK: Private

  private var mockError: ErrorWrapper!
  private var viewModel: SetupSDKErrorViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
