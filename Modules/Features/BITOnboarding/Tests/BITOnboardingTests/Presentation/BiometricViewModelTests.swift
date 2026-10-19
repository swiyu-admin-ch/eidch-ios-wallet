import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITCore
@testable import BITLocalAuthentication
@testable import BITOnboarding
@testable import BITSettings
@testable import BITTestingCore

@MainActor
final class BiometricViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()

    router = MockOnboardingInternalRoutes()

    let getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    getBiometricTypeUseCase.callAsFunctionReturnValue = .faceID
    self.getBiometricTypeUseCase = getBiometricTypeUseCase
    let hasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
    hasBiometricAuthUseCase.callAsFunctionReturnValue = true
    self.hasBiometricAuthUseCase = hasBiometricAuthUseCase
    let requestBiometricAuthUseCase = RequestBiometricAuthUseCaseProtocolSpy()
    self.requestBiometricAuthUseCase = requestBiometricAuthUseCase
    let updateBiometricUsageUseCase = UpdateBiometricUsageUseCaseProtocolSpy()
    self.updateBiometricUsageUseCase = updateBiometricUsageUseCase
    context = OnboardingContext()
    let internalLAContext = LAContextProtocolSpy()
    self.internalLAContext = internalLAContext

    Container.shared.getBiometricTypeUseCase.register { @MainActor in getBiometricTypeUseCase }
    Container.shared.hasBiometricAuthUseCase.register { @MainActor in hasBiometricAuthUseCase }
    Container.shared.requestBiometricAuthUseCase.register { @MainActor in requestBiometricAuthUseCase }
    Container.shared.updateBiometricUsageUseCase.register { @MainActor in updateBiometricUsageUseCase }
    Container.shared.internalLAContext.register { @MainActor in internalLAContext }

    viewModel = BiometricsViewModel(router: router)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testInit() {
    XCTAssertTrue(getBiometricTypeUseCase.callAsFunctionCalled)
    XCTAssertEqual(getBiometricTypeUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(hasBiometricAuthUseCase.callAsFunctionCallsCount, 1)
    XCTAssertFalse(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertFalse(updateBiometricUsageUseCase.callAsFunctionCalled)

    XCTAssertTrue(viewModel.hasBiometricAuth)
    XCTAssertEqual(viewModel.biometricType, .faceID)
  }

  func testRegisterBiometrics() async {
    context.pincode = "123456"

    await viewModel.registerBiometrics()

    XCTAssertTrue(getBiometricTypeUseCase.callAsFunctionCalled)
    XCTAssertEqual(getBiometricTypeUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(hasBiometricAuthUseCase.callAsFunctionCallsCount, 1)
    XCTAssertTrue(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertEqual(requestBiometricAuthUseCase.callAsFunctionReasonContextCallsCount, 1)
    XCTAssertEqual(updateBiometricUsageUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(updateBiometricUsageUseCase.callAsFunctionReceivedUsage, .enabled)

    XCTAssertTrue(router.setupCalled)
    XCTAssertNil(viewModel.error)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testPrimaryActionWithBiometricsUnavailable_continuesWithoutRequestingBiometrics() async {
    hasBiometricAuthUseCase.callAsFunctionReturnValue = false
    viewModel.checkBiometricStatus()

    await viewModel.primaryAction()

    XCTAssertTrue(router.setupCalled)
    XCTAssertFalse(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertFalse(updateBiometricUsageUseCase.callAsFunctionCalled)
  }

  func testPrimaryActionWithBiometricsAvailable_requestsBiometrics() async {
    await viewModel.primaryAction()

    XCTAssertTrue(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertEqual(updateBiometricUsageUseCase.callAsFunctionReceivedUsage, .enabled)
    XCTAssertTrue(router.setupCalled)
  }

  func testRegisterBiometricsWithError_presentsErrorWithoutContinuing() async {
    requestBiometricAuthUseCase.callAsFunctionReasonContextThrowableError = TestingError.error

    await viewModel.registerBiometrics()

    XCTAssertTrue(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertFalse(updateBiometricUsageUseCase.callAsFunctionCalled)
    XCTAssertFalse(router.setupCalled)
    XCTAssertEqual(viewModel.error as? TestingError, .error)
    XCTAssertTrue(viewModel.isErrorPresented)
  }

  @MainActor
  func testRegisterBiometricsWithBiometricNotAvailable_updatesUsageToDisabledAndContinues() async {
    requestBiometricAuthUseCase.callAsFunctionReasonContextThrowableError = AuthError.biometricNotAvailable

    await viewModel.registerBiometrics()

    XCTAssertEqual(updateBiometricUsageUseCase.callAsFunctionReceivedUsage, .disabled)
    XCTAssertTrue(router.setupCalled)
    XCTAssertNil(viewModel.error)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testRegisterBiometricsWithUnexpectedError_presentsError() async {
    requestBiometricAuthUseCase.callAsFunctionReasonContextThrowableError = TestingError.error

    await viewModel.registerBiometrics()

    XCTAssertFalse(updateBiometricUsageUseCase.callAsFunctionCalled)
    XCTAssertFalse(router.setupCalled)
    XCTAssertEqual(viewModel.error as? TestingError, .error)
    XCTAssertTrue(viewModel.isErrorPresented)
  }

  func testWillEnterForeground() async {
    NotificationCenter.default.post(name: .willEnterForeground, object: nil, userInfo: nil)

    try? await Task.sleep(nanoseconds: 200_000_000)

    XCTAssertTrue(getBiometricTypeUseCase.callAsFunctionCalled)
    XCTAssertEqual(getBiometricTypeUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(hasBiometricAuthUseCase.callAsFunctionCallsCount, 2)
    XCTAssertFalse(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    XCTAssertFalse(updateBiometricUsageUseCase.callAsFunctionCalled)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional
  private var viewModel: BiometricsViewModel!
  private var context: OnboardingContext!
  private var internalLAContext: LAContextProtocolSpy!
  private var router: MockOnboardingInternalRoutes!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!
  private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocolSpy!
  private var requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocolSpy!
  private var updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocolSpy!
  // swiftlint:enable implicitly_unwrapped_optional

}
