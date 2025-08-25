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

    mockHasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
    mockIsBiometricUsageAllowedUseCase = IsBiometricUsageAllowedUseCaseProtocolSpy()
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

    mockHasBiometricAuthUseCase.executeReturnValue = false
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = false
    mockIsBiometricInvalidatedUseCase.executeReturnValue = false
    mockGetBiometricTypeUseCase.executeReturnValue = .faceID

    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = 0
    mockFetchVersionEnforcementUseCase.executeWithTimeoutReturnValue = nil

    mockUseCases = LoginUseCasesProtocolSpy()
    mockUseCases.hasBiometricAuth = mockHasBiometricAuthUseCase
    mockUseCases.isBiometricUsageAllowed = mockIsBiometricUsageAllowedUseCase
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

    Container.shared.loginUseCases.register { self.mockUseCases }
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
  func testWithInitialData_withBiometricsTypeNone() async {
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockHasBiometricAuthUseCase.executeReturnValue = true
    mockGetBiometricTypeUseCase.executeReturnValue = BiometricType.none

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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)
  }

  @MainActor
  func testWithInitialData_withBiometricsAvailable() async {
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockHasBiometricAuthUseCase.executeReturnValue = true

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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)

    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertEqual(mockIsBiometricInvalidatedUseCase.executeCallsCount, 1)
    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertEqual(mockHasBiometricAuthUseCase.executeCallsCount, 1)
  }

  @MainActor
  func testInitLockWithExceededAttempts() async {
    let attemptLimit = 2
    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.executeReturnValue = 10
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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindReceivedInvocations, [.appPin, .biometric])
    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testInitLockWithExceededAttemptsButLockTimeIsDone() async {
    let attemptLimit = 2
    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.executeReturnValue = -10

    Container.shared.attemptsLimit.register { attemptLimit }
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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertTrue(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testRestartTimerAfterRebootWithTooManyAttempts() async {
    let attemptLimit = 2
    let lockDelay: TimeInterval = 10
    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.executeClosure = {
      self.mockGetLockedWalletTimeLeftUseCase.executeCallsCount == 1 ? 100000 : lockDelay
      // 100000 simulates a reboot value. So the first call on getLockedWallet (in configure will return 100000 aka a reboot)
    }

    Container.shared.attemptsLimit.register { attemptLimit }
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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertTrue(mockLockWalletUseCase.executeCalled)
  }

  @MainActor
  func testRestartTimerAfterReboot() async {
    let attemptLimit = 2
    let lockDelay: TimeInterval = 10
    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = attemptLimit
    mockGetLockedWalletTimeLeftUseCase.executeClosure = {
      self.mockGetLockedWalletTimeLeftUseCase.executeCallsCount == 1 ? 100000 : lockDelay
      // 100000 simulates a reboot value. So the first call on getLockedWallet (in configure will return 100000 aka a reboot)
    }

    Container.shared.attemptsLimit.register { attemptLimit }
    Container.shared.lockDelay.register { lockDelay }

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

    XCTAssertTrue(mockGetLoginAttemptCounterUseCase.executeKindCalled)
    // 2 call in the configure
    XCTAssertEqual(mockGetLoginAttemptCounterUseCase.executeKindCallsCount, 2)

    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertFalse(mockResetLoginAttemptCounterUseCase.executeCalled)
    XCTAssertTrue(mockLockWalletUseCase.executeCalled)
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
    XCTAssertFalse(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertEqual(mockLoginPinCodeUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
    XCTAssertEqual(1, mockIsBiometricUsageAllowedUseCase.executeCallsCount)
    XCTAssertFalse(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testPinCodeAttemptFailure() async {
    mockRegisterLoginAttemptCounterUseCase.executeKindReturnValue = 1
    Container.shared.lockDelay.register { 0 }
    let viewModel = LoginViewModel(router: mockRouter)
    await attemptWithFailure(viewModel: viewModel)
  }

  @MainActor
  func testPinCodeAttemptFailure_thenSuccess() async {
    mockRegisterLoginAttemptCounterUseCase.executeKindReturnValue = 1
    mockGetLoginAttemptCounterUseCase.executeKindReturnValue = 1
    Container.shared.loadingDelay.register { 0 }
    let viewModel = LoginViewModel(router: mockRouter)
    await attemptWithFailure(viewModel: viewModel)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 1)

    mockLoginPinCodeUseCase.executeFromThrowableError = nil

    viewModel.pinCode = "123456"

    viewModel.pinCodeAuthentication()

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertFalse(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertEqual(2, mockLoginPinCodeUseCase.executeFromCallsCount)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
    XCTAssertEqual(1, mockIsBiometricUsageAllowedUseCase.executeCallsCount)
  }

  @MainActor
  func testBiometricAuthHappyPath() async throws {
    mockHasBiometricAuthUseCase.executeReturnValue = true
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockIsBiometricInvalidatedUseCase.executeReturnValue = false

    Container.shared.loadingDelay.register { 0 }
    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    try? await Task.sleep(nanoseconds: 200_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)

    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.executeCalled)
    XCTAssertEqual(1, mockLoginBiometricUseCase.executeCallsCount) // because of the configure in init
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testBiometricAttemptFailure_deviceHasBiometric() async {
    mockHasBiometricAuthUseCase.executeReturnValue = false
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockIsBiometricInvalidatedUseCase.executeReturnValue = false

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
  }

  @MainActor
  func testBiometricAttemptFailure_biometricNotAllowed() async {
    mockHasBiometricAuthUseCase.executeReturnValue = true
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = false
    mockIsBiometricInvalidatedUseCase.executeReturnValue = false

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertFalse(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
  }

  @MainActor
  func testBiometricAttemptFailure_invalidatedData() async {
    mockHasBiometricAuthUseCase.executeReturnValue = true
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockIsBiometricInvalidatedUseCase.executeReturnValue = true

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
  }

  @MainActor
  func testBiometricAttemptFailure() async {
    mockHasBiometricAuthUseCase.executeReturnValue = true
    mockIsBiometricUsageAllowedUseCase.executeReturnValue = true
    mockIsBiometricInvalidatedUseCase.executeReturnValue = false
    mockLoginBiometricUseCase.executeThrowableError = TestingError.error
    mockRegisterLoginAttemptCounterUseCase.executeKindReturnValue = 1

    viewModel = LoginViewModel(router: mockRouter)
    await viewModel.promptBiometricAuthentication()

    try? await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.biometricAttempts, 1)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)
    XCTAssertFalse(viewModel.isBiometricTriggered)

    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertTrue(mockRegisterLoginAttemptCounterUseCase.executeKindCalled)
    XCTAssertEqual(mockRegisterLoginAttemptCounterUseCase.executeKindCallsCount, 1)
  }

  @MainActor
  func testLockedState() async {
    let maxAttempts = 3
    let delay: TimeInterval = 5
    await lockedState(maxAttempts: maxAttempts, delay: delay)

    XCTAssertTrue(mockLockWalletUseCase.executeCalled)
    XCTAssertEqual(mockLockWalletUseCase.executeCallsCount, 1)
    XCTAssertTrue(viewModel.isLocked)
    XCTAssertEqual(viewModel.biometricAttempts, 0)
    XCTAssertEqual(viewModel.attempts, maxAttempts)
    XCTAssertEqual(mockRegisterLoginAttemptCounterUseCase.executeKindCallsCount, maxAttempts)
  }

  @MainActor
  func testLockedStateMoreAttempts() async {
    let maxAttempts = 5
    let delay: TimeInterval = 5
    await lockedState(maxAttempts: maxAttempts, delay: delay)

    XCTAssertTrue(viewModel.isLocked)
    XCTAssertEqual(viewModel.biometricAttempts, 0)
    XCTAssertEqual(viewModel.attempts, maxAttempts)

    XCTAssertTrue(mockLockWalletUseCase.executeCalled)
    XCTAssertEqual(mockLockWalletUseCase.executeCallsCount, 1)
    XCTAssertTrue(mockGetLockedWalletTimeLeftUseCase.executeCalled)
    XCTAssertEqual(mockGetLockedWalletTimeLeftUseCase.executeCallsCount, 2)
    XCTAssertFalse(mockUnlockWalletUseCase.executeCalled)
  }

  @MainActor
  func testBiometricLoginWithVersionEnforcementBlock() async throws {
    mockFetchVersionEnforcementUseCase.executeWithTimeoutReturnValue = mockVersionEnforcement

    try await testBiometricAuthHappyPath()

    XCTAssertFalse(mockRouter.closeWithCompletionCalled)
    XCTAssertTrue(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
    XCTAssertEqual(mockRouter.versionEnforcement, mockVersionEnforcement)
  }

  @MainActor
  func testBiometricLoginWithoutVersionEnforcementBlock() async throws {
    mockFetchVersionEnforcementUseCase.executeWithTimeoutReturnValue = nil

    try await testBiometricAuthHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testPinLoginWithoutVersionEnforcementBlock() async throws {
    mockFetchVersionEnforcementUseCase.executeWithTimeoutReturnValue = nil

    await testPinCodeHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  @MainActor
  func testPinLoginWithVersionEnforcementBlock() async throws {
    mockFetchVersionEnforcementUseCase.executeWithTimeoutReturnValue = mockVersionEnforcement

    await testPinCodeHappyPath()

    XCTAssertFalse(mockRouter.closeWithCompletionCalled)
    XCTAssertTrue(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
    XCTAssertEqual(mockRouter.versionEnforcement, mockVersionEnforcement)
  }

  @MainActor
  func testVersionEnforcementSilentFail() async throws {
    mockFetchVersionEnforcementUseCase.executeWithTimeoutThrowableError = TestingError.error

    await testPinCodeHappyPath()

    XCTAssertTrue(mockRouter.closeWithCompletionCalled)
    XCTAssertFalse(mockRouter.didCallversionEnforcement)
    XCTAssertTrue(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }

  // MARK: Private

  private var mockHasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
  private var mockIsBiometricUsageAllowedUseCase = IsBiometricUsageAllowedUseCaseProtocolSpy()
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
  private var mockVersionEnforcement = VersionEnforcement.Mock.sample
  // swiftlint:disable all
  private var viewModel: LoginViewModel!
  // swiftlint:enable all
  private var isLoginRequiredNotificationTriggered = false

  @MainActor
  private func lockedState(maxAttempts: Int, delay: TimeInterval) async {
    mockGetLockedWalletTimeLeftUseCase.executeReturnValue = nil
    Container.shared.attemptsLimit.register { maxAttempts }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)
    XCTAssertFalse(mockUnlockWalletUseCase.executeCalled)

    for i in 1...maxAttempts {
      mockRegisterLoginAttemptCounterUseCase.executeKindReturnValue = i
      if i == maxAttempts {
        let timeInterval = delay
        mockGetLockedWalletTimeLeftUseCase.executeReturnValue = timeInterval
        Task { @MainActor in
          let duration = UInt64(timeInterval * 1_000_000_000)
          try? await Task.sleep(nanoseconds: duration)
          mockGetLockedWalletTimeLeftUseCase.executeReturnValue = 0
        }
      }
      await attemptWithFailure(viewModel: viewModel)
      XCTAssertEqual(viewModel.attempts, i)
    }
  }

  @MainActor
  private func biometricLockedState(maxAttempts: Int, delay: TimeInterval) async {
    mockGetLockedWalletTimeLeftUseCase.executeReturnValue = nil
    Container.shared.attemptsLimit.register { maxAttempts }
    viewModel = LoginViewModel(router: mockRouter)
    XCTAssertFalse(mockLockWalletUseCase.executeCalled)
    XCTAssertFalse(mockUnlockWalletUseCase.executeCalled)

    for i in 1...maxAttempts {
      mockRegisterLoginAttemptCounterUseCase.executeKindReturnValue = i
      if i == maxAttempts {
        let timeInterval = delay
        mockGetLockedWalletTimeLeftUseCase.executeReturnValue = timeInterval
        Task { @MainActor in
          let duration = UInt64(timeInterval * 1_000_000_000)
          try? await Task.sleep(nanoseconds: duration)
          mockGetLockedWalletTimeLeftUseCase.executeReturnValue = 0
        }
      }
      await biometricAttemptFailure(viewModel: viewModel)
      XCTAssertEqual(viewModel.biometricAttempts, i)
    }
  }

  @MainActor
  private func biometricAttemptFailure(viewModel: LoginViewModel) async {
    mockLoginBiometricUseCase.executeThrowableError = TestingError.error

    await viewModel.promptBiometricAuthentication()

    XCTAssertTrue(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertTrue(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertTrue(mockLoginBiometricUseCase.executeCalled)
  }

  @MainActor
  private func attemptWithFailure(viewModel: LoginViewModel) async {
    mockLoginPinCodeUseCase.executeFromThrowableError = TestingError.error

    viewModel.pinCode = inputPinCode

    viewModel.pinCodeAuthentication()

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(mockRouter.closeCalled)
    XCTAssertFalse(viewModel.isBiometricAuthenticationAvailable)

    XCTAssertFalse(mockHasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(mockIsBiometricUsageAllowedUseCase.executeCalled)
    XCTAssertTrue(mockLoginPinCodeUseCase.executeFromCalled)
    XCTAssertFalse(mockLoginBiometricUseCase.executeCalled)
    XCTAssertEqual(1, mockIsBiometricUsageAllowedUseCase.executeCallsCount)
    XCTAssertFalse(mockIsBiometricInvalidatedUseCase.executeCalled)
    XCTAssertFalse(mockFetchVersionEnforcementUseCase.executeWithTimeoutCalled)
  }
}
