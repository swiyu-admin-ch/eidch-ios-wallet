import BITL10n
import DeviceCheck
import XCTest
@testable import BITEIDRequest

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate

class ValidateAttestationsErrorViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    mockError = NSError(domain: "", code: 0, userInfo: nil)
    router = MockEIDRequestRouter()
    delegate = ValidateAttestationsErrorDelegateSpy()
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: mockError)
  }

  @MainActor
  func testInitialState_insufficientKeyStorageResistanceError() {
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: EIDRequestRepository.Error.insufficientKeyStorageResistance)

    XCTAssertFalse(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationNotSupportedTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationNotSupportedBody)
  }

  @MainActor
  func testInitialState_DCErrorTimeoutError() {
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: DCError(.serverUnavailable))

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationDeviceCheckTimeoutTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationDeviceCheckTimeoutBody)
  }

  @MainActor
  func testInitialState_DCError() {
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: DCError(.invalidInput))

    XCTAssertFalse(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationDeviceCheckErrorTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationDeviceCheckErrorBody)
  }

  @MainActor
  func testInitialState_unknownError() {
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: FetchAttestationsUseCaseError.networkError)

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestClientAttestationServiceErrorTitle)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestClientAttestationServiceErrorBody)
  }

  @MainActor
  func testInitialState_unhandledError() {
    viewModel = ValidateAttestationsErrorViewModel(router: router, delegate: delegate, error: mockError)

    XCTAssertTrue(viewModel.isRetryEnabled)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestAttestationUnknownErrorPrimary)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestAttestationUnknownErrorSecondary)
  }

  @MainActor
  func testPrimaryAction() {
    viewModel.primaryAction()

    XCTAssertTrue(router.popCalled)
    XCTAssertTrue(delegate.didTapPrimaryActionCalled)
  }

  @MainActor
  func testSecondaryAction() {
    viewModel.secondaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var mockError: Error!
  private var router: MockEIDRequestRouter!
  private var viewModel: ValidateAttestationsErrorViewModel!
  private var delegate: ValidateAttestationsErrorDelegateSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
