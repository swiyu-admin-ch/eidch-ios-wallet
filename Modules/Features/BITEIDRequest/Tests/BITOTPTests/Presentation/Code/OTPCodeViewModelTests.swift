import BITL10n
import Factory
import Spyable
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

@MainActor
final class OTPCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    verifyOTPUseCase = VerifyOTPUseCaseProtocolSpy()
    setOTPEnabledUseCase = SetOTPEnabledUseCaseProtocolSpy()

    Container.shared.verifyOTPUseCase.register { @MainActor in self.verifyOTPUseCase }
    Container.shared.setOTPEnabledUseCase.register { @MainActor in self.setOTPEnabledUseCase }
  }

  func testOnCodeChange_sanitizesToSixDigits() {
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("12a34-5678")

    XCTAssertEqual(viewModel.code, "123456")
  }

  func testOnCodeChange_keepsOnlyDecimalDigitsFromPastedValue() {
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("12Ⅻ٣a4½5")

    XCTAssertEqual(viewModel.code, "12345")
  }

  func testOnCodeChange_withSixDigits_autoSubmits() async {
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("123456")
    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(verifyOTPUseCase.callAsFunctionEmailCodeReceivedInvocations.count, 1)
    XCTAssertEqual(verifyOTPUseCase.callAsFunctionEmailCodeReceivedInvocations.first?.email, "user@example.admin.ch")
    XCTAssertEqual(verifyOTPUseCase.callAsFunctionEmailCodeReceivedInvocations.first?.code, "123456")
  }

  func testSubmit_success_navigatesToEIDRequest() async {
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")
    viewModel.onCodeChange("123456")
    await viewModel.submit()

    switch viewModel.destination {
    case .external(.eidRequest):
      XCTAssertTrue(true)
    default:
      XCTFail("Expected navigation to eID request")
    }
    XCTAssertEqual(setOTPEnabledUseCase.callAsFunctionCallsCount, 1)
  }

  func testSubmit_whileSubmitting_doesNotTriggerVerification() async {
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")
    viewModel.code = "123456"
    viewModel.isSubmitting = true

    await viewModel.submit()

    XCTAssertEqual(verifyOTPUseCase.callAsFunctionEmailCodeReceivedInvocations.count, 0)
  }

  func testSubmit_invalidCode_showsInlineErrorAndDisablesSubmit() async {
    verifyOTPUseCase.callAsFunctionEmailCodeThrowableError = OTPError.invalidFormat
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("123456")
    await viewModel.submit()

    XCTAssertEqual(viewModel.errorMessage, L10n.tkEidRequestOtpCodeErrorInvalid)
    XCTAssertFalse(viewModel.isSubmissionAllowed)
  }

  func testSubmit_expiredOTP_setsToastAndDismissesToEmail() async {
    verifyOTPUseCase.callAsFunctionEmailCodeThrowableError = OTPError.otpExpired
    var toastMessage: String?
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch", onToastMessage: { toastMessage = $0 })

    viewModel.onCodeChange("123456")
    await viewModel.submit()

    XCTAssertEqual(toastMessage, L10n.tkEidRequestOtpCodeToastExpired)
    XCTAssertTrue(viewModel.isBackTriggered)
  }

  func testSubmit_tooManyRequests_navigatesToTooManyAttempts() async {
    verifyOTPUseCase.callAsFunctionEmailCodeThrowableError = OTPError.tooManyRequests
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("123456")
    await viewModel.submit()

    switch viewModel.destination {
    case .error(.OTP.tooManyAttempts):
      XCTAssertTrue(true)
    default:
      XCTFail("Expected too many attempts screen")
    }
    XCTAssertFalse(viewModel.isBackTriggered)
  }

  func testSubmit_serviceDeactivated_navigatesToUnavailable() async {
    verifyOTPUseCase.callAsFunctionEmailCodeThrowableError = OTPError.serviceDeactivated
    let viewModel = OTPCodeViewModel(email: "user@example.admin.ch")

    viewModel.onCodeChange("123456")
    await viewModel.submit()

    switch viewModel.destination {
    case .error(.OTP.unavailable):
      XCTAssertTrue(true)
    default:
      XCTFail("Expected unavailable screen")
    }
  }

  // MARK: Private

  private var verifyOTPUseCase: VerifyOTPUseCaseProtocolSpy!
  private var setOTPEnabledUseCase: SetOTPEnabledUseCaseProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
