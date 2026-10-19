import Factory
import XCTest
@testable import BITOTP
@testable import BITSettings

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
final class SettingsViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    let isOTPEnabledUseCase = IsOTPEnabledUseCaseProtocolSpy()
    self.isOTPEnabledUseCase = isOTPEnabledUseCase
    let setOTPEnabledUseCase = SetOTPEnabledUseCaseProtocolSpy()
    self.setOTPEnabledUseCase = setOTPEnabledUseCase

    Container.shared.isOTPDebugToggleEnabled.register { true }
    Container.shared.isOTPEnabledUseCase.register { @MainActor in isOTPEnabledUseCase }
    Container.shared.setOTPEnabledUseCase.register { @MainActor in setOTPEnabledUseCase }
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testInit_whenDebugToggleDisabled_hidesToggleAndDoesNotReadFlag() {
    Container.shared.isOTPDebugToggleEnabled.register { false }

    let viewModel = SettingsViewModel()

    XCTAssertFalse(viewModel.isOTPDebugToggleVisible)
    XCTAssertFalse(viewModel.isOTPEnabled)
    XCTAssertEqual(isOTPEnabledUseCase.callAsFunctionCallsCount, 0)
  }

  func testInit_readsOTPEnabledState() {
    isOTPEnabledUseCase.callAsFunctionReturnValue = true

    let viewModel = SettingsViewModel()

    XCTAssertTrue(viewModel.isOTPDebugToggleVisible)
    XCTAssertTrue(viewModel.isOTPEnabled)
    XCTAssertEqual(isOTPEnabledUseCase.callAsFunctionCallsCount, 1)
  }

  func testToggleOTPEnabled_togglesAndPersistsState() {
    isOTPEnabledUseCase.callAsFunctionReturnValue = true
    let viewModel = SettingsViewModel()

    viewModel.toggleOTPEnabled()

    XCTAssertFalse(viewModel.isOTPEnabled)
    XCTAssertEqual(setOTPEnabledUseCase.callAsFunctionCallsCount, 1)
  }

  func testToggleOTPEnabled_whenDebugToggleDisabled_doesNothing() {
    Container.shared.isOTPDebugToggleEnabled.register { false }
    let viewModel = SettingsViewModel()

    viewModel.toggleOTPEnabled()

    XCTAssertEqual(setOTPEnabledUseCase.callAsFunctionCallsCount, 0)
  }

  // MARK: Private

  private var isOTPEnabledUseCase: IsOTPEnabledUseCaseProtocolSpy!
  private var setOTPEnabledUseCase: SetOTPEnabledUseCaseProtocolSpy!
}
