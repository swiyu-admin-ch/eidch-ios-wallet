import Factory
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class CurrentPinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    getUniquePassphraseUseCase = GetUniquePassphraseUseCaseProtocolSpy()
    lockWalletUseCase = LockWalletUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase.executeKindReturnValue = 0

    Container.shared.getUniquePassphraseUseCase.register { self.getUniquePassphraseUseCase }
    Container.shared.lockWalletUseCase.register { self.lockWalletUseCase }
    Container.shared.getLoginAttemptCounterUseCase.register { self.getLoginAttemptCounterUseCase }
    Container.shared.pinCodeMinimumSize.register { 6 }
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState() {
    let viewModel = Container.shared.currentPinCodeViewModel(ChangePinRouterMock())
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(viewModel.isSubmitEnabled)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNil(viewModel.router.context.newPinCode)
  }

  @MainActor
  func testInitialState_whenAttemptsAreGreaterThanZero() {
    let router = ChangePinRouterMock()
    let attempts = 4
    getLoginAttemptCounterUseCase.executeKindReturnValue = attempts

    let viewModel = CurrentPinCodeViewModel(router: router)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, attempts)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
  }

  @MainActor
  func testCurrentPinCode_success() {
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.executeFromReturnValue = Data()
    let viewModel = CurrentPinCodeViewModel(router: router)

    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)

    XCTAssertNotNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertTrue(router.newPinCodeCalled)
  }

  @MainActor
  func testCurrentPinCode_error() {
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.executeFromThrowableError = PinCodeError.wrongPinCode
    let viewModel = CurrentPinCodeViewModel(router: router)

    viewModel.submit()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.newPinCodeCalled)
  }

  @MainActor
  func testCurrentPinCode_lockWallet() {
    let logoutExpectation = XCTNSNotificationExpectation(name: .logout)
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.executeFromThrowableError = PinCodeError.wrongPinCode

    Container.shared.attemptsLimit.register { 2 }
    let viewModel = CurrentPinCodeViewModel(router: router)

    viewModel.submit()
    viewModel.submit()

    wait(for: [logoutExpectation], timeout: 2)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 2)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.newPinCodeCalled)
    XCTAssertTrue(lockWalletUseCase.executeCalled)
  }

  @MainActor
  func testUnlockWallet() async throws {
    let logoutExpectation = XCTNSNotificationExpectation(name: .logout)
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.executeFromThrowableError = PinCodeError.wrongPinCode

    Container.shared.attemptsLimit.register { 2 }
    let viewModel = CurrentPinCodeViewModel(router: router)

    viewModel.submit()
    viewModel.submit()

    await fulfillment(of: [logoutExpectation], timeout: 2)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 2)
    XCTAssertEqual(viewModel.inputFieldState, .error)

    XCTAssertNil(viewModel.router.context.uniquePassphrase)
    XCTAssertNil(viewModel.router.context.newPinCode)
    XCTAssertFalse(router.newPinCodeCalled)
    XCTAssertTrue(lockWalletUseCase.executeCalled)

    viewModel.onAppear()

    try await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
  }

  // MARK: Private

  // swiftlint:disable all
  private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocolSpy!
  private var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocolSpy!
  private var lockWalletUseCase: LockWalletUseCaseProtocolSpy!
  // swiftlint:enable all

}
