import Factory
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class CurrentPinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState() {
    registerDependencies()

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
    let (_, getLoginAttemptCounterUseCase, _) = registerDependencies()
    let router = ChangePinRouterMock()
    let attempts = 4
    getLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = attempts

    let viewModel = CurrentPinCodeViewModel(router: router)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, attempts)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
  }

  @MainActor
  func testCurrentPinCode_success() {
    let (getUniquePassphraseUseCase, _, _) = registerDependencies()
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = Data()
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
    let (getUniquePassphraseUseCase, _, _) = registerDependencies()
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = PinCodeError.wrongPinCode
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
    let (getUniquePassphraseUseCase, _, lockWalletUseCase) = registerDependencies()
    let logoutExpectation = XCTNSNotificationExpectation(name: .logout)
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = PinCodeError.wrongPinCode

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
    XCTAssertTrue(lockWalletUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testUnlockWallet() async throws {
    let (getUniquePassphraseUseCase, _, lockWalletUseCase) = registerDependencies()
    let logoutExpectation = XCTNSNotificationExpectation(name: .logout)
    let router = ChangePinRouterMock()

    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = PinCodeError.wrongPinCode

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
    XCTAssertTrue(lockWalletUseCase.callAsFunctionCalled)

    viewModel.onAppear()

    try await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
  }

  // MARK: Private

  @MainActor
  @discardableResult
  private func registerDependencies() -> (
    GetUniquePassphraseUseCaseProtocolSpy,
    GetLoginAttemptCounterUseCaseProtocolSpy,
    LockWalletUseCaseProtocolSpy)
  {
    let getUniquePassphraseUseCase = GetUniquePassphraseUseCaseProtocolSpy()
    let lockWalletUseCase = LockWalletUseCaseProtocolSpy()
    let getLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0

    Container.shared.getUniquePassphraseUseCase.register { @MainActor in getUniquePassphraseUseCase }
    Container.shared.lockWalletUseCase.register { @MainActor in lockWalletUseCase }
    Container.shared.getLoginAttemptCounterUseCase.register { @MainActor in getLoginAttemptCounterUseCase }
    Container.shared.pinCodeMinimumSize.register { 6 }

    return (getUniquePassphraseUseCase, getLoginAttemptCounterUseCase, lockWalletUseCase)
  }

}
