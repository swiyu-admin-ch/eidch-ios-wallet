import BITL10n
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class NewPinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState() {
    let (_, viewModel, _) = makeSUT()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.toast)
    XCTAssertEqual(viewModel.inputFieldMessage, L10n.tkOnboardingCharactersSubtitle)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertNotNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNotNil(viewModel.router.context.newPinCodeDelegate)
    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  @MainActor
  func testPinCode_success() {
    let (router, viewModel, validatePinCodeRuleUseCase) = makeSUT()

    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldMessage, L10n.tkOnboardingCharactersSubtitle)
    XCTAssertEqual(viewModel.inputFieldState, .normal)

    XCTAssertTrue(router.confirmNewPinCodeCalled)
    XCTAssertEqual(router.context.newPinCode, viewModel.pinCode)
    XCTAssertTrue(validatePinCodeRuleUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinCode_error() {
    let (router, viewModel, validatePinCodeRuleUseCase) = makeSUT()
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.tooShort

    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.confirmNewPinCodeCalled)
    XCTAssertTrue(validatePinCodeRuleUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinCode_didRequestValidation() {
    let (router, _, validatePinCodeRuleUseCase) = makeSUT()
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.tooShort
    let viewModel = Container.shared.newPinCodeViewModel(router)

    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.confirmNewPinCodeCalled)

    viewModel.pinCode = "1234"

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.confirmNewPinCodeCalled)

    validatePinCodeRuleUseCase.callAsFunctionThrowableError = nil

    viewModel.pinCode = "12345"

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldMessage, L10n.tkOnboardingCharactersSubtitle)
    XCTAssertEqual(viewModel.inputFieldState, .normal)

    XCTAssertFalse(router.confirmNewPinCodeCalled)
    XCTAssertNil(router.context.newPinCode, viewModel.pinCode)
  }

  // MARK: Private

  @MainActor
  private func makeSUT() -> (ChangePinRouterMock, NewPinCodeViewModel, ValidatePinCodeRuleUseCaseProtocolSpy) {
    let router = ChangePinRouterMock()
    router.context.uniquePassphrase = "123456".data(using: .utf8)

    let validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()
    Container.shared.pinCodeMinimumSize.register { 6 }
    Container.shared.validatePinCodeRuleUseCase.register { @MainActor in validatePinCodeRuleUseCase }

    let viewModel = NewPinCodeViewModel(router: router)
    return (router, viewModel, validatePinCodeRuleUseCase)
  }
}
