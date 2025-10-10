import Factory
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class ConfirmPinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  // swiftlint:disable all
  var router = ChangePinRouterMock()

  // swiftlint:enable all

  @MainActor
  override func setUp() {
    super.setUp()

    router = ChangePinRouterMock()
    router.context.uniquePassphrase = pinCode.data(using: .utf8)
    router.context.newPinCode = pinCode

    validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()
    updatePinCodeUseCase = UpdatePinCodeUseCaseProtocolSpy()

    Container.shared.validatePinCodeRuleUseCase.register { self.validatePinCodeRuleUseCase }
    Container.shared.updatePinCodeUseCase.register { self.updatePinCodeUseCase }
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState() {
    let viewModel = ConfirmPinCodeViewModel(router: router)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.attempts, 0)
  }

  @MainActor
  func testPinCode_success() {
    validatePinCodeRuleUseCase.executeThrowableError = nil
    updatePinCodeUseCase.executeWithAndThrowableError = nil

    let viewModel = ConfirmPinCodeViewModel(router: router)
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
    validatePinCodeRuleUseCase.executeThrowableError = nil

    let viewModel = ConfirmPinCodeViewModel(router: router)
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
    validatePinCodeRuleUseCase.executeThrowableError = PinCodeError.tooShort

    let viewModel = ConfirmPinCodeViewModel(router: router)
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

    validatePinCodeRuleUseCase.executeThrowableError = PinCodeError.empty
    let viewModel = ConfirmPinCodeViewModel(router: router)

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

  // swiftlint: disable all
  private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocolSpy!
  private var updatePinCodeUseCase: UpdatePinCodeUseCaseProtocolSpy!
  // swiftlint: enable all

}
