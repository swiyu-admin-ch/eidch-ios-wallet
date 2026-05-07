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
    hasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
    hasBiometricAuthUseCase.executeReturnValue = true

    lockWalletUseCase = LockWalletUseCaseProtocolSpy()
    registerLoginAttemptCounterUseCase = RegisterLoginAttemptCounterUseCaseProtocolSpy()
    registerLoginAttemptCounterUseCase.executeKindReturnValue = 0
    getLoginAttemptCounterUseCase = GetLoginAttemptCounterUseCaseProtocolSpy()
    getLoginAttemptCounterUseCase.executeKindReturnValue = 0
    resetLoginAttemptCounterUseCase = ResetLoginAttemptCounterUseCaseProtocolSpy()
    isBiometricUsageAllowedUseCase = IsBiometricUsageAllowedUseCaseProtocolSpy()
    isBiometricUsageAllowedUseCase.executeReturnValue = true
    getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    getBiometricTypeUseCase.executeReturnValue = .faceID

    Container.shared.getUniquePassphraseUseCase.register { @MainActor in self.getUniquePassphraseUseCase }
    Container.shared.changeBiometricStatusUseCase.register { @MainActor in self.changeBiometricStatusUseCase }
    Container.shared.hasBiometricAuthUseCase.register { @MainActor in self.hasBiometricAuthUseCase }

    Container.shared.lockWalletUseCase.register { @MainActor in self.lockWalletUseCase }
    Container.shared.registerLoginAttemptCounterUseCase.register { @MainActor in self.registerLoginAttemptCounterUseCase }
    Container.shared.getLoginAttemptCounterUseCase.register { @MainActor in self.getLoginAttemptCounterUseCase }
    Container.shared.resetLoginAttemptCounterUseCase.register { @MainActor in self.resetLoginAttemptCounterUseCase }
    Container.shared.isBiometricUsageAllowedUseCase.register { @MainActor in self.isBiometricUsageAllowedUseCase }
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
    XCTAssertTrue(viewModel.isBiometricEnabled)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
    XCTAssertFalse(viewModel.isSubmitEnabled)
  }

  @MainActor
  func testInitialState_noBiometricAuth() {
    hasBiometricAuthUseCase.executeReturnValue = false
    let viewModel = BiometricChangeViewModel(router: router)
    XCTAssertEqual(viewModel.state, .disabledBiometrics)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertEqual(viewModel.biometricType, .faceID)
    XCTAssertFalse(viewModel.isBiometricEnabled)
    XCTAssertTrue(viewModel.pinCode.isEmpty)
  }

  @MainActor
  func testHappyPath() async {
    let pinCode = "123456"
    let mockData = Data()
    getUniquePassphraseUseCase.executeFromReturnValue = mockData

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertTrue(viewModel.isSubmitEnabled)
    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedPinCode, pinCode)
    XCTAssertTrue(hasBiometricAuthUseCase.executeCalled)
    XCTAssertTrue(changeBiometricStatusUseCase.executeWithCalled)
  }

  @MainActor
  func testPassphraseFailure() async {
    let pinCode = "123456"
    registerLoginAttemptCounterUseCase.executeKindReturnValue = 1
    getUniquePassphraseUseCase.executeFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedInvocations.first, pinCode)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)
  }

  @MainActor
  func testPassphraseFailure_thenSuccess() async {
    let pinCode = "123456"
    registerLoginAttemptCounterUseCase.executeKindReturnValue = 1
    getUniquePassphraseUseCase.executeFromThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 1)

    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedInvocations.first, pinCode)

    let data = Data()
    getUniquePassphraseUseCase.executeFromThrowableError = nil
    getUniquePassphraseUseCase.executeFromReturnValue = data

    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedInvocations.first, pinCode)
    XCTAssertTrue(hasBiometricAuthUseCase.executeCalled)
    XCTAssertEqual(changeBiometricStatusUseCase.executeWithReceivedUniquePassphrase, data)
  }

  @MainActor
  func testChangeBiometricStatus_failure() async {
    let pinCode = "123456"
    let data = Data()
    getUniquePassphraseUseCase.executeFromReturnValue = data
    changeBiometricStatusUseCase.executeWithThrowableError = TestingError.error

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .error)
    XCTAssertNotNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedInvocations.first, pinCode)
  }

  @MainActor
  func testChangeBiometricStatus_userCancel() async {
    let pinCode = "123456"
    let data = Data()
    getUniquePassphraseUseCase.executeFromReturnValue = data
    changeBiometricStatusUseCase.executeWithThrowableError = ChangeBiometricStatusError.userCancel

    let viewModel = BiometricChangeViewModel(router: router)
    viewModel.pinCode = pinCode
    await viewModel.submit()

    XCTAssertFalse(viewModel.pinCode.isEmpty)
    XCTAssertEqual(viewModel.inputFieldState, .normal)
    XCTAssertNil(viewModel.inputFieldMessage)
    XCTAssertEqual(viewModel.attempts, 0)

    XCTAssertEqual(getUniquePassphraseUseCase.executeFromReceivedInvocations.first, pinCode)
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
  private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocolSpy!
  private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocolSpy!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!

  private var router: BiometricChangeRouterRoutes!
  // swiftlint:enable all

}
