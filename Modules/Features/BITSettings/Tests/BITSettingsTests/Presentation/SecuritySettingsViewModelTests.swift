import Factory
import Spyable
import XCTest
@testable import BITAppAuth
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
    isBiometricUsageAllowedUseCase.executeReturnValue = true
    hasBiometricAuthUseCase.executeReturnValue = true
    getBiometricTypeUseCase.executeReturnValue = .faceID

    viewModel.onAppear()

    XCTAssertTrue(viewModel.isBiometricEnabled)
    XCTAssertEqual(viewModel.biometricType, .faceID)
  }

  func testOnAppear_useCasesCalled() {
    viewModel.onAppear()

    XCTAssertEqual(isBiometricUsageAllowedUseCase.executeCallsCount, 1)
    XCTAssertEqual(hasBiometricAuthUseCase.executeCallsCount, 1)
    XCTAssertEqual(getBiometricTypeUseCase.executeCallsCount, 1)
    XCTAssertEqual(fetchAnalyticStatusUseCase.executeCallsCount, 1)
  }

  func testOnAppear_biometricNotAllowed_biometricIsDisabled() {
    isBiometricUsageAllowedUseCase.executeReturnValue = false
    hasBiometricAuthUseCase.executeReturnValue = true

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isBiometricEnabled)
  }

  func testOnAppear_biometricDisabled_biometricIsDisabled() {
    isBiometricUsageAllowedUseCase.executeReturnValue = true
    hasBiometricAuthUseCase.executeReturnValue = false

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isBiometricEnabled)
  }

  func testOnAppear_analyticsEnabled_correctState() {
    fetchAnalyticStatusUseCase.executeReturnValue = true

    viewModel.onAppear()

    XCTAssertTrue(viewModel.isAnalyticsEnabled)
    XCTAssertFalse(viewModel.isAnalyticsLoading)
  }

  func testOnAppear_analyticsDisabled_correctState() {
    fetchAnalyticStatusUseCase.executeReturnValue = false

    viewModel.onAppear()

    XCTAssertFalse(viewModel.isAnalyticsEnabled)
    XCTAssertFalse(viewModel.isAnalyticsLoading)
  }

  func testUpdateAnalyticsStatus_togglesStatus() async {
    let isAnalyticsEnabbled = viewModel.isAnalyticsEnabled

    await viewModel.updateAnalyticsStatus()

    XCTAssertEqual(updateAnalyticsStatusUseCase.executeIsAllowedCallsCount, 1)
    XCTAssertEqual(viewModel.isAnalyticsEnabled, !isAnalyticsEnabbled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: SecuritySettingsViewModel!
  private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocolSpy!
  private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocolSpy!
  private var fetchAnalyticStatusUseCase: FetchAnalyticStatusUseCaseProtocolSpy!
  private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocolSpy!
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy!

  // swiftlint:enable all

  private func setupMocks() {
    hasBiometricAuthUseCase = HasBiometricAuthUseCaseProtocolSpy()
    getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    isBiometricUsageAllowedUseCase = IsBiometricUsageAllowedUseCaseProtocolSpy()
    updateAnalyticsStatusUseCase = UpdateAnalyticStatusUseCaseProtocolSpy()
    fetchAnalyticStatusUseCase = FetchAnalyticStatusUseCaseProtocolSpy()

    Container.shared.hasBiometricAuthUseCase.register { self.hasBiometricAuthUseCase }
    Container.shared.getBiometricTypeUseCase.register { self.getBiometricTypeUseCase }
    Container.shared.isBiometricUsageAllowedUseCase.register { self.isBiometricUsageAllowedUseCase }
    Container.shared.updateAnalyticsStatusUseCase.register { self.updateAnalyticsStatusUseCase }
    Container.shared.fetchAnalyticStatusUseCase.register { self.fetchAnalyticStatusUseCase }
  }

  private func success() {
    hasBiometricAuthUseCase.executeReturnValue = true
    getBiometricTypeUseCase.executeReturnValue = .touchID
    isBiometricUsageAllowedUseCase.executeReturnValue = true
    fetchAnalyticStatusUseCase.executeReturnValue = true
  }

}
