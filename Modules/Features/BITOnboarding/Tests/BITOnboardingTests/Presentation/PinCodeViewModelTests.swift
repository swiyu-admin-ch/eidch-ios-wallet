import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding

// MARK: - PinCodeViewModelTests

final class PinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()
    spyDelegate = PinCodeDelegateSpy()
    router = MockOnboardingInternalRoutes()
    router.context.pinCodeDelegate = spyDelegate
    validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()

    Container.shared.validatePinCodeRuleUseCase.register {
      self.validatePinCodeRuleUseCase
    }

    viewModel = PinCodeViewModel(router: router)
  }

  @MainActor
  func testEnterValidPinCode() {
    let pinCode = "12345678"
    viewModel.pinCode = pinCode

    viewModel.validate()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.error)

    XCTAssertTrue(router.pinCodeConfirmationCalled)
    XCTAssertEqual(router.context.pincode, pinCode)

    XCTAssertTrue(router.pinCodeConfirmationCalled)
  }

  @MainActor
  func testEnterLongPinCode_noDelegate() {
    let pinCode = "123456789qwertzuiop"
    viewModel.pinCode = pinCode

    viewModel.validate()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.error)

    XCTAssertTrue(router.pinCodeConfirmationCalled)
    XCTAssertEqual(router.context.pincode, pinCode)
  }

  @MainActor
  func testEnterShortPinCode() {
    validatePinCodeRuleUseCase.executeThrowableError = PinCodeError.tooShort
    viewModel.pinCode = "1234"

    viewModel.validate()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.error)

    XCTAssertFalse(router.pinCodeConfirmationCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: PinCodeViewModel!
  private var router: MockOnboardingInternalRoutes!
  private var spyDelegate: PinCodeDelegateSpy!

  private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocolSpy!
  // swiftlint:enable all

}
