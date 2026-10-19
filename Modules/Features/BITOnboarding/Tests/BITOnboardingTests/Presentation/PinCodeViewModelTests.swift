import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding

// MARK: - PinCodeViewModelTests

@MainActor
final class PinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    spyDelegate = PinCodeDelegateSpy()
    router = MockOnboardingInternalRoutes()
    router.context.pinCodeDelegate = spyDelegate
    let validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()
    self.validatePinCodeRuleUseCase = validatePinCodeRuleUseCase

    Container.shared.validatePinCodeRuleUseCase.register {
      validatePinCodeRuleUseCase
    }

    viewModel = PinCodeViewModel(router: router)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

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

  func testEnterShortPinCode() {
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.tooShort
    viewModel.pinCode = "1234"

    viewModel.validate()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.error)

    XCTAssertFalse(router.pinCodeConfirmationCalled)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional
  private var viewModel: PinCodeViewModel!
  private var router: MockOnboardingInternalRoutes!
  // swiftlint:disable:next weak_delegate
  private var spyDelegate: PinCodeDelegateSpy!

  private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocolSpy!
  // swiftlint:enable implicitly_unwrapped_optional

}
