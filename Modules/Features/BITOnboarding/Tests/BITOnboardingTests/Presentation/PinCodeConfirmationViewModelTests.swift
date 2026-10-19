import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding

// MARK: - PinCodeViewModelTests

@MainActor
final class PinCodeConfirmationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()

    spyDelegate = PinCodeDelegateSpy()
    router = MockOnboardingInternalRoutes()
    router.context.pincode = pincode
    router.context.pinCodeDelegate = spyDelegate
    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .disabled
    self.getBiometricStateUseCase = getBiometricStateUseCase
    Container.shared.getBiometricStateUseCase.register { @MainActor in getBiometricStateUseCase }
    viewModel = PinCodeConfirmationViewModel(router: router)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testEnterValidPinCodeWithDisabledBiometrics() {
    viewModel.pinCode = pincode

    viewModel.validate()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertTrue(router.biometricsCalled)
    XCTAssertFalse(router.setupCalled)
    XCTAssertEqual(router.context.pincode, pincode)
  }

  func testEnterValidPinCodeWithEnabledBiometrics() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    viewModel.pinCode = pincode

    viewModel.validate()

    XCTAssertTrue(router.biometricsCalled)
    XCTAssertFalse(router.setupCalled)
  }

  func testEnterValidPinCodeWithDeclinedBiometrics() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .declined
    viewModel.pinCode = pincode

    viewModel.validate()

    XCTAssertFalse(router.biometricsCalled)
    XCTAssertTrue(router.setupCalled)
  }

  func testEnterValidPinCodeWithNotEnrolledBiometrics() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .notEnrolled
    viewModel.pinCode = pincode

    viewModel.validate()

    XCTAssertFalse(router.biometricsCalled)
    XCTAssertTrue(router.setupCalled)
  }

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

  // swiftlint:disable implicitly_unwrapped_optional
  private var viewModel: PinCodeConfirmationViewModel!
  private var router: MockOnboardingInternalRoutes!
  // swiftlint:disable:next weak_delegate
  private var spyDelegate: PinCodeDelegateSpy!
  private var context: PinCodeContext!
  private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy!

  private let pincode = "123456789"
  // swiftlint:enable implicitly_unwrapped_optional

}
