import Factory
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class BiometricChangeViewModelTests: XCTestCase {

  // MARK: Internal

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState_hasBiometricAuth() {
    let dependencies = makeDependencies()
    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    XCTAssertEqual(viewModel.state, .password)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.biometricType, .faceID)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  @MainActor
  func testInitialState_noBiometricAuth() {
    let dependencies = makeDependencies()
    dependencies.getBiometricStateUseCase.callAsFunctionReturnValue = .notEnrolled
    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    XCTAssertEqual(viewModel.state, .disabledBiometrics)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.biometricType, .faceID)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
  }

  @MainActor
  func testHappyPath() async {
    let dependencies = makeDependencies()
    let pinCode = "123456"
    let mockData = Data()
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromReturnValue = mockData

    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertTrue(viewModel.isSubmitEnabled)
    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedPinCode, pinCode)
    XCTAssertTrue(dependencies.getBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertTrue(dependencies.changeBiometricStatusUseCase.callAsFunctionWithCalled)
  }

  @MainActor
  func testPassphraseFailure() async {
    let dependencies = makeDependencies()
    let pinCode = "123456"
    dependencies.registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)
  }

  @MainActor
  func testPassphraseFailure_thenSuccess() async {
    let dependencies = makeDependencies()
    let pinCode = "123456"
    dependencies.registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)

    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)

    let data = Data()
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromThrowableError = nil
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data

    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
    XCTAssertTrue(dependencies.getBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertEqual(dependencies.changeBiometricStatusUseCase.callAsFunctionWithReceivedUniquePassphrase, data)
  }

  @MainActor
  func testChangeBiometricStatus_failure() async {
    let dependencies = makeDependencies()
    let pinCode = "123456"
    let data = Data()
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data
    dependencies.changeBiometricStatusUseCase.callAsFunctionWithThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
  }

  @MainActor
  func testChangeBiometricStatus_userCancel() async {
    let dependencies = makeDependencies()
    let pinCode = "123456"
    let data = Data()
    dependencies.getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data
    dependencies.changeBiometricStatusUseCase.callAsFunctionWithThrowableError = ChangeBiometricStatusError.userCancel

    let viewModel = BiometricChangeViewModel(router: dependencies.router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(dependencies.getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
  }

  // MARK: Private

  private struct Dependencies {
    let router: BiometricChangeRouterRoutes
    let getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocolSpy
    let lockWalletUseCase: LockWalletUseCaseProtocolSpy
    let registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocolSpy
    let getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocolSpy
    let resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocolSpy
    let changeBiometricStatusUseCase: ChangeBiometricStatusUseCaseProtocolSpy
    let getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy
    let getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy
  }

  @MainActor
  private func makeDependencies() -> Dependencies {
    let router = BiometricChangeRouterRoutesMock()
    let getUniquePassphraseUseCase = GetUniquePassphraseUseCaseProtocolSpy()
    let changeBiometricStatusUseCase = ChangeBiometricStatusUseCaseProtocolSpy()
    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled

    let lockWalletUseCase = LockWalletUseCaseProtocolSpy()
    let registerLoginAttemptCounterUseCase = RegisterLoginAttemptCounterUseCaseProtocolSpy()
    registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0
    let getLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0
    let resetLoginAttemptCounterUseCase = ResetLoginAttemptCounterUseCaseProtocolSpy()
    let getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    getBiometricTypeUseCase.callAsFunctionReturnValue = .faceID
    let pinCodeSize = 6

    Container.shared.getUniquePassphraseUseCase.register { @MainActor in getUniquePassphraseUseCase }
    Container.shared.changeBiometricStatusUseCase.register { @MainActor in changeBiometricStatusUseCase }
    Container.shared.getBiometricStateUseCase.register { @MainActor in getBiometricStateUseCase }

    Container.shared.lockWalletUseCase.register { @MainActor in lockWalletUseCase }
    Container.shared.registerLoginAttemptCounterUseCase.register { @MainActor in registerLoginAttemptCounterUseCase }
    Container.shared.getLoginAttemptCounterUseCase.register { @MainActor in getLoginAttemptCounterUseCase }
    Container.shared.resetLoginAttemptCounterUseCase.register { @MainActor in resetLoginAttemptCounterUseCase }
    Container.shared.getBiometricTypeUseCase.register { @MainActor in getBiometricTypeUseCase }
    Container.shared.pinCodeMinimumSize.register { @MainActor in pinCodeSize }

    return Dependencies(
      router: router,
      getUniquePassphraseUseCase: getUniquePassphraseUseCase,
      lockWalletUseCase: lockWalletUseCase,
      registerLoginAttemptCounterUseCase: registerLoginAttemptCounterUseCase,
      getLoginAttemptCounterUseCase: getLoginAttemptCounterUseCase,
      resetLoginAttemptCounterUseCase: resetLoginAttemptCounterUseCase,
      changeBiometricStatusUseCase: changeBiometricStatusUseCase,
      getBiometricStateUseCase: getBiometricStateUseCase,
      getBiometricTypeUseCase: getBiometricTypeUseCase)
  }

}
