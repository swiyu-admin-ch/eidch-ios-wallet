import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITCore
@testable import BITLocalAuthentication
@testable import BITOnboarding
@testable import BITSettings

final class BiometricViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    router = MockOnboardingInternalRoutes()

    getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    getBiometricTypeUseCase.executeReturnValue = .faceID
    hasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
    hasBiometricAuthUseCase.executeReturnValue = true
    requestBiometricAuthUseCase = RequestBiometricAuthUseCaseProtocolSpy()
    allowBiometricUsageUseCase = AllowBiometricUsageUseCaseProtocolSpy()
    context = OnboardingContext()
    internalLAContext = LAContextProtocolSpy()

    Container.shared.getBiometricTypeUseCase.register { self.getBiometricTypeUseCase }
    Container.shared.hasBiometricAuthUseCase.register { self.hasBiometricAuthUseCase }
    Container.shared.requestBiometricAuthUseCase.register { self.requestBiometricAuthUseCase }
    Container.shared.allowBiometricUsageUseCase.register { self.allowBiometricUsageUseCase }
    Container.shared.internalLAContext.register { self.internalLAContext }

    viewModel = BiometricsViewModel(router: router)
  }

  @MainActor
  func testInit() {
    XCTAssertTrue(getBiometricTypeUseCase.executeCalled)
    XCTAssertEqual(getBiometricTypeUseCase.executeCallsCount, 1)
    XCTAssertTrue(hasBiometricAuthUseCase.executeCalled)
    XCTAssertEqual(hasBiometricAuthUseCase.executeCallsCount, 1)
    XCTAssertFalse(requestBiometricAuthUseCase.executeReasonContextCalled)
    XCTAssertFalse(allowBiometricUsageUseCase.executeAllowCalled)

    XCTAssertTrue(viewModel.hasBiometricAuth)
    XCTAssertEqual(viewModel.biometricType, .faceID)
  }

  @MainActor
  func testRegisterBiometrics() async {
    context.pincode = "123456"

    await viewModel.registerBiometrics()

    XCTAssertTrue(getBiometricTypeUseCase.executeCalled)
    XCTAssertEqual(getBiometricTypeUseCase.executeCallsCount, 1)
    XCTAssertTrue(hasBiometricAuthUseCase.executeCalled)
    XCTAssertEqual(hasBiometricAuthUseCase.executeCallsCount, 1)
    XCTAssertTrue(requestBiometricAuthUseCase.executeReasonContextCalled)
    XCTAssertEqual(requestBiometricAuthUseCase.executeReasonContextCallsCount, 1)
    XCTAssertTrue(allowBiometricUsageUseCase.executeAllowCalled)
    XCTAssertEqual(allowBiometricUsageUseCase.executeAllowCallsCount, 1)

    XCTAssertTrue(router.setupCalled)
    XCTAssertNil(viewModel.error)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testWillEnterForeground() async {
    NotificationCenter.default.post(name: .willEnterForeground, object: nil, userInfo: nil)

    try? await Task.sleep(nanoseconds: 200_000_000)

    XCTAssertTrue(getBiometricTypeUseCase.executeCalled)
    XCTAssertEqual(getBiometricTypeUseCase.executeCallsCount, 2)
    XCTAssertTrue(hasBiometricAuthUseCase.executeCalled)
    XCTAssertEqual(hasBiometricAuthUseCase.executeCallsCount, 2)
    XCTAssertFalse(requestBiometricAuthUseCase.executeReasonContextCalled)
    XCTAssertFalse(allowBiometricUsageUseCase.executeAllowCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: BiometricsViewModel!
  private var context: OnboardingContext!
  private var internalLAContext: LAContextProtocolSpy!
  private var router: MockOnboardingInternalRoutes!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!
  private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocolSpy!
  private var requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocolSpy!
  private var allowBiometricUsageUseCase: AllowBiometricUsageUseCaseProtocolSpy!
  // swiftlint:enable all

}
