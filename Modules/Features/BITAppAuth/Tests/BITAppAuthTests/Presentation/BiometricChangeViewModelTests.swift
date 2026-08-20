import Factory
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

final class BiometricChangeViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    router = BiometricChangeRouterRoutesMock()
    getUniquePassphraseUseCase = GetUniquePassphraseUseCaseProtocolSpy()
    changeBiometricStatusUseCase = ChangeBiometricStatusUseCaseProtocolSpy()
    getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled

    lockWalletUseCase = LockWalletUseCaseProtocolSpy()
    registerLoginAttemptCounterUseCase = RegisterLoginAttemptCounterUseCaseProtocolSpy()
    registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0
    getLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 0
    resetLoginAttemptCounterUseCase = ResetLoginAttemptCounterUseCaseProtocolSpy()
    getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    getBiometricTypeUseCase.callAsFunctionReturnValue = .faceID

    Container.shared.getUniquePassphraseUseCase.register { @MainActor in self.getUniquePassphraseUseCase }
    Container.shared.changeBiometricStatusUseCase.register { @MainActor in self.changeBiometricStatusUseCase }
    Container.shared.getBiometricStateUseCase.register { @MainActor in self.getBiometricStateUseCase }

    Container.shared.lockWalletUseCase.register { @MainActor in self.lockWalletUseCase }
    Container.shared.registerLoginAttemptCounterUseCase.register { @MainActor in self.registerLoginAttemptCounterUseCase }
    Container.shared.getLoginAttemptCounterUseCase.register { @MainActor in self.getLoginAttemptCounterUseCase }
    Container.shared.resetLoginAttemptCounterUseCase.register { @MainActor in self.resetLoginAttemptCounterUseCase }
    Container.shared.getBiometricTypeUseCase.register { @MainActor in self.getBiometricTypeUseCase }
    Container.shared.pinCodeMinimumSize.register { @MainActor in self.pinCodeSize }
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  @MainActor
  func testInitialState_hasBiometricAuth() {
    let viewModel = BiometricChangeViewModel(router: router)
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
    getBiometricStateUseCase.callAsFunctionReturnValue = .notEnrolled
    let viewModel = BiometricChangeViewModel(router: router)
    XCTAssertEqual(viewModel.state, .disabledBiometrics)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.biometricType, .faceID)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
  }

  @MainActor
  func testHappyPath() async {
    let pinCode = "123456"
    let mockData = Data()
    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = mockData

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertTrue(viewModel.isSubmitEnabled)
    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedPinCode, pinCode)
    XCTAssertTrue(getBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertTrue(changeBiometricStatusUseCase.callAsFunctionWithCalled)
  }

  @MainActor
  func testPassphraseFailure() async {
    let pinCode = "123456"
    registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)
  }

  @MainActor
  func testPassphraseFailure_thenSuccess() async {
    let pinCode = "123456"
    registerLoginAttemptCounterUseCase.callAsFunctionKindReturnValue = 1
    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)

    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)

    let data = Data()
    getUniquePassphraseUseCase.callAsFunctionFromThrowableError = nil
    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data

    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
    XCTAssertTrue(getBiometricStateUseCase.callAsFunctionCalled)
    XCTAssertEqual(changeBiometricStatusUseCase.callAsFunctionWithReceivedUniquePassphrase, data)
  }

  @MainActor
  func testChangeBiometricStatus_failure() async {
    let pinCode = "123456"
    let data = Data()
    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data
    changeBiometricStatusUseCase.callAsFunctionWithThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
  }

  @MainActor
  func testChangeBiometricStatus_userCancel() async {
    let pinCode = "123456"
    let data = Data()
    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = data
    changeBiometricStatusUseCase.callAsFunctionWithThrowableError = ChangeBiometricStatusError.userCancel

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(getUniquePassphraseUseCase.callAsFunctionFromReceivedInvocations.first, pinCode)
  }

  // MARK: Private

  // swiftlint:disable all
  private var pinCodeSize = 6
  private var isPresented = true

  private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocolSpy!
  private var lockWalletUseCase: LockWalletUseCaseProtocolSpy!
  private var registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocolSpy!
  private var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocolSpy!
  private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocolSpy!
  private var changeBiometricStatusUseCase: ChangeBiometricStatusUseCaseProtocolSpy!
  private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!

  private var router: BiometricChangeRouterRoutes!
  // swiftlint:enable all

}
