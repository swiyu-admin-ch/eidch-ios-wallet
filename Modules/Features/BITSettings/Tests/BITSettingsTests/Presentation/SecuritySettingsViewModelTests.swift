import Factory
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITCore
@testable import BITSettings

final class SecuritySettingsViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    setupMocks()
    viewModel = SecuritySettingsViewModel()
    success()
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isBiometricEnabled)
    XCTAssertFalse(viewModel.isAnalyticsEnabled)
    XCTAssertFalse(viewModel.isAnalyticsLoading)
    XCTAssertEqual(viewModel.biometricType, .none)
    XCTAssertNil(viewModel.toast)
  }

  func testOnAppear_faceIDAllowedAndEnabled_faceIDIsEnabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    getBiometricTypeUseCase.callAsFunctionReturnValue = .faceID

    viewModel.onAppear()

    XCTAssertTrue(viewModel.isBiometricEnabled)
    XCTAssertEqual(viewModel.biometricType, .faceID)
  }

  func testOnAppear_useCasesCalled() {
    viewModel.onAppear()

    XCTAssertEqual(getBiometricStateUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getBiometricTypeUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(isAnalyticsEnabledUseCase.callAsFunctionCallsCount, 1)
  }

  func testOnAppear_biometricNotAllowed_biometricIsDisabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .disabled

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isBiometricEnabled)
  }

  func testOnAppear_biometricDisabled_biometricIsDisabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .declined

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isBiometricEnabled)
  }

  func testOnAppear_analyticsEnabled_correctState() {
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = true

    viewModel.onAppear()

    XCTAssertTrue(viewModel.isAnalyticsEnabled)
    XCTAssertFalse(viewModel.isAnalyticsLoading)
  }

  func testOnAppear_analyticsDisabled_correctState() {
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = false

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isAnalyticsEnabled)
    XCTAssertFalse(viewModel.isAnalyticsLoading)
  }

  func testUpdateAnalyticsStatus_togglesStatus() async {
    let isAnalyticsEnabbled = viewModel.isAnalyticsEnabled

    await viewModel.updateAnalyticsStatus()

    XCTAssertEqual(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCallsCount, 1)
    XCTAssertEqual(viewModel.isAnalyticsEnabled, !isAnalyticsEnabbled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: SecuritySettingsViewModel!
  private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy!
  private var isAnalyticsEnabledUseCase: IsAnalyticsEnabledUseCaseProtocolSpy!
  private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocolSpy!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!
  private var applicationService: ApplicationServiceProtocolSpy!

  // swiftlint:enable all

  private func setupMocks() {
    getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    updateAnalyticsStatusUseCase = UpdateAnalyticStatusUseCaseProtocolSpy()
    isAnalyticsEnabledUseCase = IsAnalyticsEnabledUseCaseProtocolSpy()
    applicationService = ApplicationServiceProtocolSpy()

    Container.shared.getBiometricStateUseCase.register { self.getBiometricStateUseCase }
    Container.shared.getBiometricTypeUseCase.register { self.getBiometricTypeUseCase }
    Container.shared.updateAnalyticsStatusUseCase.register { self.updateAnalyticsStatusUseCase }
    Container.shared.isAnalyticsEnabledUseCase.register { self.isAnalyticsEnabledUseCase }
    Container.shared.applicationService.register { self.applicationService }
  }

  private func success() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    getBiometricTypeUseCase.callAsFunctionReturnValue = .touchID
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = true
    applicationService.openOptionsReturnValue = true
  }

}
