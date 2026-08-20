// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import Foundation
import Spyable
import SwiftUI
import XCTest
@testable import BITActivity
@testable import BITAppAuth
@testable import BITCore
@testable import BITOnboarding
@testable import BITSettings
@testable import BITTestingCore

final class SetupViewModelTests: XCTestCase {

  // MARK: Internal

  @AppStorage(UserDefaultsKey.rootOnboardingIsEnabled.rawValue) var isOnboardingEnabled = true

  @MainActor
  override func setUp() {
    super.setUp()
    registerMocks()
    isOnboardingEnabled = true
    router = MockOnboardingInternalRoutes()
    viewModel = SetupViewModel(router: router)
  }

  @MainActor
  func testRunSetup() async {
    router.context.pincode = "123456"
    router.context.analyticsOptIn = true

    await viewModel.run()

    XCTAssertEqual(registerPinCodeUseCase.callAsFunctionPinCodeCallsCount, 1)
    XCTAssertEqual(registerPinCodeUseCase.callAsFunctionPinCodeReceivedPinCode, router.context.pincode)

    XCTAssertEqual(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCallsCount, 1)
    XCTAssertEqual(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedReceivedIsAllowed, router.context.analyticsOptIn)

    XCTAssertEqual(setActivityHistoryEnabledUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(setActivityHistoryEnabledUseCase.callAsFunctionReceivedIsEnabled, true)

    XCTAssertTrue(router.completedCalled)
    XCTAssertFalse(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRunSetupWithoutPin() async {
    router.context.pincode = nil

    await viewModel.run()

    XCTAssertFalse(registerPinCodeUseCase.callAsFunctionPinCodeCalled)
    XCTAssertFalse(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCalled)
    XCTAssertFalse(setActivityHistoryEnabledUseCase.callAsFunctionCalled)

    XCTAssertFalse(router.completedCalled)
    XCTAssertTrue(router.setupErrorCalled)
    XCTAssertTrue(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRunSetupError() async {
    registerPinCodeUseCase.callAsFunctionPinCodeThrowableError = TestingError.error
    router.context.pincode = "123456"

    await viewModel.run()

    XCTAssertTrue(registerPinCodeUseCase.callAsFunctionPinCodeCalled)
    XCTAssertEqual(registerPinCodeUseCase.callAsFunctionPinCodeCallsCount, 1)
    XCTAssertFalse(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCalled)
    XCTAssertFalse(setActivityHistoryEnabledUseCase.callAsFunctionCalled)
    XCTAssertFalse(router.completedCalled)
    XCTAssertTrue(router.setupErrorCalled)
    XCTAssertTrue(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRestartSetup() async {
    router.context.pincode = "123456"

    viewModel.restartSetup()

    try? await Task.sleep(nanoseconds: 3_000_000_000)

    XCTAssertTrue(registerPinCodeUseCase.callAsFunctionPinCodeCalled)
    XCTAssertTrue(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCalled)
    XCTAssertTrue(setActivityHistoryEnabledUseCase.callAsFunctionCalled)

    XCTAssertFalse(viewModel.isOnboardingEnabled)

    try? await Task.sleep(nanoseconds: 2_100_000_000)
    XCTAssertTrue(router.completedCalled)
  }

  // MARK: Private

  private var viewModel: SetupViewModel!
  private var router: MockOnboardingInternalRoutes!
  private var registerPinCodeUseCase: RegisterPinCodeUseCaseProtocolSpy!
  private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocolSpy!
  private var setActivityHistoryEnabledUseCase: SetActivityHistoryEnabledUseCaseProtocolSpy!

  private func registerMocks() {
    registerPinCodeUseCase = RegisterPinCodeUseCaseProtocolSpy()
    updateAnalyticsStatusUseCase = UpdateAnalyticStatusUseCaseProtocolSpy()
    setActivityHistoryEnabledUseCase = SetActivityHistoryEnabledUseCaseProtocolSpy()

    Container.shared.registerPinCodeUseCase.register { @MainActor in self.registerPinCodeUseCase }
    Container.shared.updateAnalyticsStatusUseCase.register { @MainActor in self.updateAnalyticsStatusUseCase }
    Container.shared.setActivityHistoryEnabledUseCase.register { @MainActor in self.setActivityHistoryEnabledUseCase }
  }
}
