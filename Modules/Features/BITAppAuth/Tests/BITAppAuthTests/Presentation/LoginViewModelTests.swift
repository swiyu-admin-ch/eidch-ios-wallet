import BITNetworking
import Combine
import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITAppInfo
@testable import BITTestingCore

// MARK: - LoginViewModelTests

final class LoginViewModelTests: XCTestCase {

  // MARK: Internal

  let inputPinCode = "123456"

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    mockGetBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    mockLoginPinCodeUseCase = LoginPinCodeUseCaseProtocolSpy()
    mockLoginBiometricUseCase = LoginBiometricUseCaseProtocolSpy()
    mockIsBiometricInvalidatedUseCase = IsBiometricInvalidatedUseCaseProtocolSpy()
    mockGetBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    mockLockWalletUseCase = LockWalletUseCaseProtocolSpy()
    mockUnlockWalletUseCase = UnlockWalletUseCaseProtocolSpy()
    mockGetLockedWalletTimeLeftUseCase = GetLockedWalletTimeLeftUseCaseProtocolSpy()
    mockGetLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    mockRegisterLoginAttemptCounterUseCase = RegisterLoginAttemptCounterUseCaseProtocolSpy()
    mockResetLoginAttemptCounterUseCase = ResetLoginAttemptCounterUseCaseProtocolSpy()
    mockFetchVersionEnforcementUseCase = FetchVersionEnforcementUseCaseProtocolSpy()

    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .disabled
    mockIsBiometricInvalidatedUseCase.callAsFunctionReturnValue = false
    mockGetBiometricTypeUseCase.callAsFunctionReturnValue = .faceID

    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0
    mockFetchVersionEnforcementUseCase.callAsFunctionReturnValue = nil

    mockUseCases = LoginUseCasesProtocolSpy()
    mockUseCases.getBiometricStateUseCase = mockGetBiometricStateUseCase
    mockUseCases.loginPinCode = mockLoginPinCodeUseCase
    mockUseCases.loginBiometric = mockLoginBiometricUseCase
    mockUseCases.isBiometricInvalidatedUseCase = mockIsBiometricInvalidatedUseCase
    mockUseCases.getBiometricTypeUseCase = mockGetBiometricTypeUseCase
    mockUseCases.lockWalletUseCase = mockLockWalletUseCase
    mockUseCases.getLockedWalletTimeLeftUseCase = mockGetLockedWalletTimeLeftUseCase
    mockUseCases.unlockWalletUseCase = mockUnlockWalletUseCase
    mockUseCases.getLoginAttemptCounterUseCase = mockGetLoginAttemptCounterUseCase
    mockUseCases.registerLoginAttemptCounterUseCase = mockRegisterLoginAttemptCounterUseCase
    mockUseCases.resetLoginAttemptCounterUseCase = mockResetLoginAttemptCounterUseCase
    mockUseCases.fetchVersionEnforcementUseCase = mockFetchVersionEnforcementUseCase

    isLoginRequiredNotificationTriggered = false
    mockRouter = LoginRouterMock()

    Container.shared.loginUseCases.register { @MainActor in self.mockUseCases }
  }

  func testLoginProductionValues() {
    let expectedAttemptNumber = 5
    let expectedLockDelay: TimeInterval = 60 * 5
    let expectedPinCodeSize = 6

    let attemptNumber = Container.shared.attemptsLimit()
    let lockDelay = Container.shared.lockDelay()
    let pinCodeSize = Container.shared.pinCodeSize()

    XCTAssertEqual(attemptNumber, expectedAttemptNumber)
    XCTAssertEqual(lockDelay, expectedLockDelay)
    XCTAssertEqual(pinCodeSize, expectedPinCodeSize)
  }

  @MainActor
  func testWithInitialData_withBiometricsTypeNone() {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    mockGetBiometricTypeUseCase.callAsFunctionReturnValue = BiometricType.none

    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertFalse(viewModel.isLocked)
    XCTAssertNil(viewModel.countdown)
    XCTAssertNil(viewModel.timeLeft)

    XCTAssertEqual(viewModel.state, .loginPassword)
    XCTAssertEqual(viewModel.biometricType, .none)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testWithInitialData_withBiometricsAvailable() {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .enabled

    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertFalse(viewModel.isLocked)
    XCTAssertNil(viewModel.countdown)
    XCTAssertNil(viewModel.timeLeft)

    XCTAssertEqual(viewModel.state, .loginBiometrics)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)

    XCTAssertEqual(mockIsBiometricInvalidatedUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(mockGetBiometricStateUseCase.callAsFunctionCallsCount, 1)
  }

  @MainActor
  func testInitLockWithExceededAttempts() {
    let attemptLimit = 2
    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = 10
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, attemptLimit)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertTrue(viewModel.isLocked)
    XCTAssertNotNil(viewModel.countdown)
    XCTAssertNotNil(viewModel.timeLeft)

    XCTAssertEqual(viewModel.state, .locked)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindReceivedInvocations, [.appPin, .biometric])
    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testInitLockWithExceededAttemptsButLockTimeIsDone() {
    let attemptLimit = 2
    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = -10

    Container.shared.attemptsLimit.register { @MainActor in attemptLimit }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertFalse(viewModel.isLocked)
    XCTAssertNil(viewModel.countdown)
    XCTAssertNil(viewModel.timeLeft)

    XCTAssertEqual(viewModel.state, .loginPassword)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertTrue(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testRestartTimerAfterRebootWithTooManyAttempts() {
    let attemptLimit = 2
    let lockDelay: TimeInterval = 10
    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionClosure = {
      self.mockGetLockedWalletTimeLeftUseCase.callAsFunctionCallsCount == 1 ? 100000 : lockDelay
      // 100000 simulates a reboot value. So the first call on getLockedWallet (in configure will return 100000 aka a reboot)
    }

    Container.shared.attemptsLimit.register { @MainActor in attemptLimit }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, attemptLimit)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertTrue(viewModel.isLocked)
    XCTAssertNotNil(viewModel.countdown)
    XCTAssertEqual(viewModel.countdown, lockDelay)

    XCTAssertEqual(viewModel.state, .locked)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLockWalletUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testRestartTimerAfterReboot() {
    let attemptLimit = 2
    let lockDelay: TimeInterval = 10
    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionClosure = {
      self.mockGetLockedWalletTimeLeftUseCase.callAsFunctionCallsCount == 1 ? 100000 : lockDelay
      // 100000 simulates a reboot value. So the first call on getLockedWallet (in configure will return 100000 aka a reboot)
    }

    Container.shared.attemptsLimit.register { @MainActor in attemptLimit }
    Container.shared.lockDelay.register { @MainActor in lockDelay }

    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.pinCodeState, PinCodeState.normal)
    XCTAssertEqual(viewModel.attempts, attemptLimit)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)
    XCTAssertTrue(viewModel.isLocked)
    XCTAssertNotNil(viewModel.countdown)
    XCTAssertEqual(viewModel.countdown, lockDelay)

    XCTAssertEqual(viewModel.state, .locked)

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLockWalletUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinCodeHappyPath() async {
    Container.shared.loadingDelay.register { 0 }
    viewModel = LoginViewModel(router: mockRouter)
    viewModel.pinCode = inputPinCode

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)

    viewModel.pinCodeAuthentication()

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)

    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertEqual(mockLoginPinCodeUseCase.callAsFunctionFromCallsCount, 1)
    XCTAssertFalse(mockLoginBiometricUseCase.callAsFunctionCalled)
    XCTAssertEqual(1, mockGetBiometricStateUseCase.callAsFunctionCallsCount)
    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinCodeAttemptFailure() async {
    mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    Container.shared.lockDelay.register { 0 }
    let viewModel = LoginViewModel(router: mockRouter)
    await attemptWithFailure(viewModel: viewModel)
  }

  @MainActor
  func testPinCodeAttemptFailure_thenSuccess() async {
    mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    mockGetLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    Container.shared.loadingDelay.register { 0 }
    let viewModel = LoginViewModel(router: mockRouter)
    await attemptWithFailure(viewModel: viewModel)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 1)

    mockLoginPinCodeUseCase.callAsFunctionFromThrowableError = nil

    viewModel.pinCode = "123456"

    viewModel.pinCodeAuthentication()

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertEqual(2, mockLoginPinCodeUseCase.callAsFunctionFromCallsCount)
    XCTAssertFalse(mockLoginBiometricUseCase.callAsFunctionCalled)
    XCTAssertEqual(1, mockGetBiometricStateUseCase.callAsFunctionCallsCount)
  }

  @MainActor
  func testBiometricAuthHappyPath() async {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    mockIsBiometricInvalidatedUseCase.callAsFunctionReturnValue = false

    Container.shared.loadingDelay.register { 0 }
    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    try? await Task.sleep(nanoseconds: 200_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)

    XCTAssertTrue(mockGetBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.callAsFunctionCalled)
    XCTAssertEqual(1, mockLoginBiometricUseCase.callAsFunctionCallsCount) // because of the configure in init
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testBiometricAttemptFailure_deviceHasBiometric() async {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .declined
    mockIsBiometricInvalidatedUseCase.callAsFunctionReturnValue = false

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testBiometricAttemptFailure_biometricNotAllowed() async {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .disabled
    mockIsBiometricInvalidatedUseCase.callAsFunctionReturnValue = false

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockGetBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testBiometricAttemptFailure() async {
    mockGetBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    mockIsBiometricInvalidatedUseCase.callAsFunctionReturnValue = false
    mockLoginBiometricUseCase.callAsFunctionThrowableError = TestingError.error
    mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    try? await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.biometricAttempts, 1)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)

    XCTAssertTrue(mockGetBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertTrue(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCalled)
    XCTAssertEqual(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, 1)
  }

  @MainActor
  func testLockedState() async {
    let maxAttempts = 3
    let delay: TimeInterval = 5
    await lockedState(maxAttempts: maxAttempts, delay: delay)

    XCTAssertTrue(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertEqual(mockLockWalletUseCase.callAsFunctionCallsCount, 1)
    XCTAssertTrue(viewModel.isLocked)
    XCTAssertEqual(viewModel.biometricAttempts, 0)
    XCTAssertEqual(viewModel.attempts, maxAttempts)
    XCTAssertEqual(mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindCallsCount, maxAttempts)
  }

  @MainActor
  func testLockedStateMoreAttempts() async {
    let maxAttempts = 5
    let delay: TimeInterval = 5
    await lockedState(maxAttempts: maxAttempts, delay: delay)

    XCTAssertTrue(viewModel.isLocked)
    XCTAssertEqual(viewModel.biometricAttempts, 0)
    XCTAssertEqual(viewModel.attempts, maxAttempts)

    XCTAssertTrue(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertEqual(mockLockWalletUseCase.callAsFunctionCallsCount, 1)
    XCTAssertTrue(mockGetLockedWalletTimeLeftUseCase.callAsFunctionCalled)
    XCTAssertEqual(mockGetLockedWalletTimeLeftUseCase.callAsFunctionCallsCount, 2)
    XCTAssertFalse(mockUnlockWalletUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testBiometricLoginWithVersionEnforcementBlock() async {
    mockFetchVersionEnforcementUseCase.callAsFunctionReturnValue = mockVersionEnforcement

    await testBiometricAuthHappyPath()

    XCTAssertFalse(mockRouter.closeWithCompletionCalled)
    XCTAssertTrue(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
    XCTAssertEqual(mockRouter.versionEnforcement, mockVersionEnforcement)
  }

  @MainActor
  func testBiometricLoginWithoutVersionEnforcementBlock() async {
    mockFetchVersionEnforcementUseCase.callAsFunctionReturnValue = nil

    await testBiometricAuthHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinLoginWithoutVersionEnforcementBlock() async {
    mockFetchVersionEnforcementUseCase.callAsFunctionReturnValue = nil

    await testPinCodeHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testPinLoginWithVersionEnforcementBlock() async {
    mockFetchVersionEnforcementUseCase.callAsFunctionReturnValue = mockVersionEnforcement

    await testPinCodeHappyPath()

    XCTAssertFalse(mockRouter.closeWithCompletionCalled)
    XCTAssertTrue(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
    XCTAssertEqual(mockRouter.versionEnforcement, mockVersionEnforcement)
  }

  @MainActor
  func testVersionEnforcementGenericErrorSilentFail() async {
    mockFetchVersionEnforcementUseCase.callAsFunctionThrowableError = TestingError.error

    await testPinCodeHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }

  @MainActor
  func testDidDismissVersionEnforcement() {
    viewModel = LoginViewModel(router: mockRouter)

    viewModel.didDismissVersionEnforcement()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled == true)
  }

  // MARK: Private

  private var mockGetBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
  private var mockLoginPinCodeUseCase = LoginPinCodeUseCaseProtocolSpy()
  private var mockLoginBiometricUseCase = LoginBiometricUseCaseProtocolSpy()
  private var mockIsBiometricInvalidatedUseCase = IsBiometricInvalidatedUseCaseProtocolSpy()
  private var mockGetBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
  private var mockLockWalletUseCase = LockWalletUseCaseProtocolSpy()
  private var mockUnlockWalletUseCase = UnlockWalletUseCaseProtocolSpy()
  private var mockGetLockedWalletTimeLeftUseCase = GetLockedWalletTimeLeftUseCaseProtocolSpy()
  private var mockGetLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
  private var mockRegisterLoginAttemptCounterUseCase = RegisterLoginAttemptCounterUseCaseProtocolSpy()
  private var mockResetLoginAttemptCounterUseCase = ResetLoginAttemptCounterUseCaseProtocolSpy()
  private var mockFetchVersionEnforcementUseCase = FetchVersionEnforcementUseCaseProtocolSpy()
  private var mockUseCases = LoginUseCasesProtocolSpy()
  private var mockRouter = LoginRouterMock()
  private var mockVersionEnforcement = VersionEnforcement.Mock.forced
  // swiftlint:disable all
  private var viewModel: LoginViewModel!
  // swiftlint:enable all
  private var isLoginRequiredNotificationTriggered = false

  @MainActor
  private func lockedState(maxAttempts: Int, delay: TimeInterval) async {
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = nil
    Container.shared.attemptsLimit.register { @MainActor in maxAttempts }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockUnlockWalletUseCase.callAsFunctionCalled)

    for i in 1...maxAttempts {
      mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = i
      if i == maxAttempts {
        let timeInterval = delay
        mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = timeInterval
        Task { @MainActor in
          let duration = UInt64(timeInterval * 1_000_000_000)
          try? await Task.sleep(nanoseconds: duration)
          mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = 0
        }
      }
      await attemptWithFailure(viewModel: viewModel)
      XCTAssertEqual(viewModel.attempts, i)
    }
  }

  @MainActor
  private func biometricLockedState(maxAttempts: Int, delay: TimeInterval) async {
    mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = nil
    Container.shared.attemptsLimit.register { @MainActor in maxAttempts }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertFalse(mockLockWalletUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockUnlockWalletUseCase.callAsFunctionCalled)

    for i in 1...maxAttempts {
      mockRegisterLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = i
      if i == maxAttempts {
        let timeInterval = delay
        mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = timeInterval
        Task { @MainActor in
          let duration = UInt64(timeInterval * 1_000_000_000)
          try? await Task.sleep(nanoseconds: duration)
          mockGetLockedWalletTimeLeftUseCase.callAsFunctionReturnValue = 0
        }
      }
      await biometricAttemptFailure(viewModel: viewModel)
      XCTAssertEqual(viewModel.biometricAttempts, i)
    }
  }

  @MainActor
  private func biometricAttemptFailure(viewModel: LoginViewModel) async {
    mockLoginBiometricUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockGetBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.callAsFunctionCalled)
  }

  @MainActor
  private func attemptWithFailure(viewModel: LoginViewModel) async {
    mockLoginPinCodeUseCase.callAsFunctionFromThrowableError = TestingError.error

    viewModel.pinCode = inputPinCode

    viewModel.pinCodeAuthentication()

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockGetBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.callAsFunctionCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.callAsFunctionFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.callAsFunctionCalled)
    XCTAssertEqual(1, mockGetBiometricStateUseCase.callAsFunctionCallsCount)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.callAsFunctionCalled)
  }
}
