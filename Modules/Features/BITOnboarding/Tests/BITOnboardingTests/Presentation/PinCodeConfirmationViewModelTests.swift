import Factory
import Foundation
import Spyable
import XCTest
@testable import BITOnboarding

// MARK: - PinCodeViewModelTests

final class PinCodeConfirmationViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    spyDelegate = PinCodeDelegateSpy()
    router = MockOnboardingInternalRoutes()
    router.context.pincode = pincode
    router.context.pinCodeDelegate = spyDelegate
    viewModel = PinCodeConfirmationViewModel(router: router)
  }

  @MainActor
  func testEnterValidPinCode() {
    viewModel.pinCode = pincode

    viewModel.validate()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertTrue(router.biometricsCalled)
    XCTAssertEqual(router.context.pincode, pincode)
  }

  @MainActor
  func testEnterOnceShortPinCode() {
    viewModel.pinCode = "111111"

    viewModel.validate()

    XCTAssertEqual(viewModel.attempts, 1)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertFalse(router.biometricsCalled)

    viewModel.pinCode = "123456789"

    viewModel.validate()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertTrue(router.biometricsCalled)
    XCTAssertEqual(router.context.pincode, pincode)
  }

  @MainActor
  func testAttemptsInfoPresented() {
    let maxAttempts = 2
    Container.shared.attemptsLimit.register { @MainActor in maxAttempts }
    viewModel = PinCodeConfirmationViewModel(router: router)

    viewModel.pinCode = "111111"

    viewModel.validate()

    XCTAssertEqual(viewModel.attempts, 1)
    XCTAssertNotNil(viewModel.inputFieldMessage)

    viewModel.validate()

    XCTAssertEqual(viewModel.attempts, 2)
    XCTAssertNotNil(viewModel.inputFieldMessage)

    XCTAssertFalse(router.biometricsCalled)
    XCTAssertTrue(router.popCalled)
    XCTAssertTrue(spyDelegate.didTryTooManyAttemptsCalled)
  }

  @MainActor
  func testMaxAttemptReached() {
    let maxAttempts = 2
    Container.shared.attemptsLimit.register { @MainActor in maxAttempts }
    viewModel = PinCodeConfirmationViewModel(router: router)

    let pinCode = "111111"
    for i in 0..<maxAttempts {
      viewModel.pinCode = "111111"
      viewModel.validate()

      XCTAssertEqual(viewModel.pinCode, pinCode)
      XCTAssertEqual(viewModel.attempts, i + 1)
      XCTAssertFalse(router.biometricsCalled)
    }

    XCTAssertNotNil(viewModel.inputFieldMessage)

    XCTAssertTrue(router.popCalled)
    XCTAssertTrue(spyDelegate.didTryTooManyAttemptsCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: PinCodeConfirmationViewModel!
  private var router: MockOnboardingInternalRoutes!
  private var spyDelegate: PinCodeDelegateSpy!
  private var context: PinCodeContext!

  private let pincode = "123456789"
  // swiftlint:enable all

}
