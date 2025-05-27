import Factory
import Foundation
import Spyable
import SwiftUI
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding
@testable import BITSettings
@testable import BITTestingCore

final class SetupViewModelTests: XCTestCase {

  // MARK: Internal

  @AppStorage("rootOnboardingIsEnabled") var isOnboardingEnabled = true

  @MainActor
  override func setUp() {
    super.setUp()

    registerPinCodeUseCase = RegisterPinCodeUseCaseProtocolSpy()
    updateAnalyticsStatusUseCase = UpdateAnalyticStatusUseCaseProtocolSpy()

    Container.shared.registerPinCodeUseCase.register { self.registerPinCodeUseCase }
    Container.shared.updateAnalyticsStatusUseCase.register { self.updateAnalyticsStatusUseCase }

    isOnboardingEnabled = true
    router = MockOnboardingInternalRoutes()
    viewModel = SetupViewModel(router: router)
  }

  @MainActor
  func testRunSetup() async {
    router.context.pincode = "123456"
    router.context.analyticsOptIn = true

    await viewModel.run()

    XCTAssertTrue(registerPinCodeUseCase.executePinCodeCalled)
    XCTAssertEqual(registerPinCodeUseCase.executePinCodeCallsCount, 1)
    XCTAssertEqual(registerPinCodeUseCase.executePinCodeReceivedPinCode, router.context.pincode)
    XCTAssertEqual(updateAnalyticsStatusUseCase.executeIsAllowedReceivedIsAllowed, router.context.analyticsOptIn)
    XCTAssertTrue(updateAnalyticsStatusUseCase.executeIsAllowedCalled)
    XCTAssertEqual(updateAnalyticsStatusUseCase.executeIsAllowedCallsCount, 1)
    XCTAssertTrue(router.completedCalled)
    XCTAssertFalse(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRunSetupWithoutPin() async {
    router.context.pincode = nil

    await viewModel.run()

    XCTAssertFalse(registerPinCodeUseCase.executePinCodeCalled)
    XCTAssertFalse(updateAnalyticsStatusUseCase.executeIsAllowedCalled)

    XCTAssertFalse(router.completedCalled)
    XCTAssertTrue(router.setupErrorCalled)
    XCTAssertTrue(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRunSetupError() async {
    registerPinCodeUseCase.executePinCodeThrowableError = TestingError.error
    router.context.pincode = "123456"

    await viewModel.run()

    XCTAssertTrue(registerPinCodeUseCase.executePinCodeCalled)
    XCTAssertEqual(registerPinCodeUseCase.executePinCodeCallsCount, 1)
    XCTAssertFalse(updateAnalyticsStatusUseCase.executeIsAllowedCalled)
    XCTAssertFalse(router.completedCalled)
    XCTAssertTrue(router.setupErrorCalled)
    XCTAssertTrue(viewModel.isOnboardingEnabled)
  }

  @MainActor
  func testRestartSetup() async {
    router.context.pincode = "123456"

    viewModel.restartSetup()

    try? await Task.sleep(nanoseconds: 3_000_000_000)

    XCTAssertTrue(registerPinCodeUseCase.executePinCodeCalled)
    XCTAssertTrue(updateAnalyticsStatusUseCase.executeIsAllowedCalled)

    XCTAssertFalse(viewModel.isOnboardingEnabled)

    try? await Task.sleep(nanoseconds: 2_100_000_000)
    XCTAssertTrue(router.completedCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: SetupViewModel!
  private var router: MockOnboardingInternalRoutes!
  private var registerPinCodeUseCase: RegisterPinCodeUseCaseProtocolSpy!
  private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocolSpy!
  // swiftlint:enable all

}
