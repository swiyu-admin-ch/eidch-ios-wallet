import Factory
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class ConfirmPinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState() {
    let (_, viewModel, _, _) = makeSUT()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.attempts, 0)
  }

  @MainActor
  func testPinCode_success() {
    let (router, viewModel, validatePinCodeRuleUseCase, updatePinCodeUseCase) = makeSUT()
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = nil
    updatePinCodeUseCase.callAsFunctionWithAndThrowableError = nil

    viewModel.pinCode = pinCode
    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertTrue(router.popCountCalled)
    XCTAssertEqual(router.popCountCalledValue, 3)
  }

  @MainActor
  func testPinCode_mismatch() {
    let (router, viewModel, validatePinCodeRuleUseCase, _) = makeSUT()
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = nil

    viewModel.pinCode = "123456789"
    viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertFalse(router.popCountCalled)
    XCTAssertEqual(viewModel.attempts, 1)
  }

  @MainActor
  func testPinCode_error() {
    let (router, viewModel, validatePinCodeRuleUseCase, _) = makeSUT()
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.tooShort

    viewModel.pinCode = "123"
    viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertFalse(router.popCountCalled)
    XCTAssertEqual(viewModel.attempts, 1)
  }

  @MainActor
  func testPinCode_TooManyAttempts() {
    Container.shared.attemptsLimitChangePinCode.register { 2 }
    let (router, viewModel, validatePinCodeRuleUseCase, _) = makeSUT()

    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.empty

    viewModel.submit()
    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertEqual(viewModel.attempts, 2)

    XCTAssertTrue(router.popCalled)
  }

  // MARK: Private

  private let pinCode = "123456"

  @MainActor
  private func makeSUT() -> (
    ChangePinRouterMock,
    ConfirmPinCodeViewModel,
    ValidatePinCodeRuleUseCaseProtocolSpy,
    UpdatePinCodeUseCaseProtocolSpy)
  {
    let router = ChangePinRouterMock()
    router.context.uniquePassphrase = pinCode.data(using: .utf8)
    router.context.newPinCode = pinCode

    let validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()
    let updatePinCodeUseCase = UpdatePinCodeUseCaseProtocolSpy()

    Container.shared.validatePinCodeRuleUseCase.register { @MainActor in validatePinCodeRuleUseCase }
    Container.shared.updatePinCodeUseCase.register { @MainActor in updatePinCodeUseCase }

    let viewModel = ConfirmPinCodeViewModel(router: router)
    return (router, viewModel, validatePinCodeRuleUseCase, updatePinCodeUseCase)
  }

}
