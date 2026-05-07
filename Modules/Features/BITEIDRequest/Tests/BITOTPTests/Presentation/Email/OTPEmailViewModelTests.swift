import BITL10n
import Factory
import Spyable
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

@MainActor
final class OTPEmailViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()
    requestOTPUseCase = RequestOTPUseCaseProtocolSpy()

    Container.shared.requestOTPUseCase.register { @MainActor in self.requestOTPUseCase }
  }

  func testInit_defaultState_emptyEmailAndInvalidFormat() {
    let viewModel = OTPEmailViewModel()

    XCTAssertEqual(viewModel.email, "")
    XCTAssertFalse(viewModel.isEmailFormatValid)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  func testOnEmailChange_invalidFormatAfterDebounce_doesNotShowInlineError() async {
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("invalid")
    try? await Task.sleep(nanoseconds: 350_000_000)

    XCTAssertFalse(viewModel.isEmailFormatValid)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  func testSubmit_invalidEmail_doesNotRequestOTP() async {
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("invalid")
    await viewModel.submit()

    XCTAssertEqual(requestOTPUseCase.callAsFunctionEmailCallsCount, 0)
    XCTAssertNil(viewModel.errorMessage)
  }

  func testSubmit_success_navigatesToCodeScreen() async {
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("User.Name@Example.Admin.CH")
    await viewModel.submit()

    XCTAssertEqual(requestOTPUseCase.callAsFunctionEmailReceivedInvocations, ["user.name@example.admin.ch"])

    switch viewModel.destination {
    case .code(let email, _):
      XCTAssertEqual(email, "user.name@example.admin.ch")
      XCTAssertTrue(true)
    default:
      XCTFail("Expected navigation to otp code")
    }
  }

  func testSubmit_forbiddenEmail_showsFieldError() async {
    requestOTPUseCase.callAsFunctionEmailThrowableError = OTPError.forbiddenEmail
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("user@example.admin.ch")
    await viewModel.submit()

    XCTAssertEqual(viewModel.errorMessage, L10n.tkEidRequestOtpEmailErrorForbidden)
    XCTAssertNil(viewModel.destination)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  func testSubmit_invalidFormatFromBackend_showsFieldError() async {
    requestOTPUseCase.callAsFunctionEmailThrowableError = OTPError.invalidFormat
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("user@example.admin.ch")
    await viewModel.submit()

    XCTAssertEqual(viewModel.errorMessage, L10n.tkEidRequestOtpEmailErrorInvalidFormat)
    XCTAssertNil(viewModel.destination)
  }

  func testSubmit_serviceDeactivated_navigatesToUnavailable() async {
    requestOTPUseCase.callAsFunctionEmailThrowableError = OTPError.serviceDeactivated
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("user@example.admin.ch")
    await viewModel.submit()

    switch viewModel.destination {
    case .error(.OTP.unavailable):
      XCTAssertTrue(true)
    default:
      XCTFail("Expected navigation to unavailable screen")
    }
  }

  func testSubmit_invalidClientAttestation_navigatesToRetryErrorScreen() async {
    requestOTPUseCase.callAsFunctionEmailThrowableError = OTPError.invalidClientAttestation
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("user@example.admin.ch")
    await viewModel.submit()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected navigation to retry error screen")
    }

    XCTAssertNil(viewModel.errorMessage)
  }

  func testSubmit_unknownError_navigatesToRetryErrorScreen() async {
    requestOTPUseCase.callAsFunctionEmailThrowableError = OTPError.unknown
    let viewModel = OTPEmailViewModel()

    viewModel.onEmailChange("user@example.admin.ch")
    await viewModel.submit()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected navigation to retry error screen")
    }

    XCTAssertNil(viewModel.errorMessage)
  }

  // MARK: Private

  private var requestOTPUseCase: RequestOTPUseCaseProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
