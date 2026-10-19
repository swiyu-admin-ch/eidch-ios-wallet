import Factory
import FactoryTesting
import Testing
@testable import BITAppAuth
@testable import BITCore
@testable import BITSettings

@Suite(.container) @MainActor
struct SecuritySettingsViewModelTests {

  // MARK: Lifecycle

  init() {
    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    let getBiometricTypeUseCase = GetBiometricTypeUseCaseProtocolSpy()
    let updateAnalyticsStatusUseCase = UpdateAnalyticStatusUseCaseProtocolSpy()
    let isAnalyticsEnabledUseCase = IsAnalyticsEnabledUseCaseProtocolSpy()
    let applicationService = ApplicationServiceProtocolSpy()

    Container.shared.getBiometricStateUseCase.register { getBiometricStateUseCase }
    Container.shared.getBiometricTypeUseCase.register { getBiometricTypeUseCase }
    Container.shared.updateAnalyticsStatusUseCase.register { updateAnalyticsStatusUseCase }
    Container.shared.isAnalyticsEnabledUseCase.register { isAnalyticsEnabledUseCase }
    Container.shared.applicationService.register { applicationService }

    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    getBiometricTypeUseCase.callAsFunctionReturnValue = .touchID
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = true
    applicationService.openOptionsReturnValue = true

    self.getBiometricStateUseCase = getBiometricStateUseCase
    self.getBiometricTypeUseCase = getBiometricTypeUseCase
    self.updateAnalyticsStatusUseCase = updateAnalyticsStatusUseCase
    self.isAnalyticsEnabledUseCase = isAnalyticsEnabledUseCase
    self.applicationService = applicationService

    viewModel = SecuritySettingsViewModel()
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(!viewModel.isBiometricEnabled)
    #expect(!viewModel.isAnalyticsEnabled)
    #expect(!viewModel.isAnalyticsLoading)
    #expect(viewModel.biometricType == .none)
    #expect(viewModel.toast == nil)
  }

  @Test
  func onAppear_faceIDAllowedAndEnabled_faceIDIsEnabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    getBiometricTypeUseCase.callAsFunctionReturnValue = .faceID

    viewModel.onAppear()

    #expect(viewModel.isBiometricEnabled)
    #expect(viewModel.biometricType == .faceID)
  }

  @Test
  func onAppear_useCasesCalled() {
    viewModel.onAppear()

    #expect(getBiometricStateUseCase.callAsFunctionCallsCount == 1)
    #expect(getBiometricTypeUseCase.callAsFunctionCallsCount == 1)
    #expect(isAnalyticsEnabledUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func onAppear_biometricNotAllowed_biometricIsDisabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .disabled

    viewModel.onAppear()

    #expect(!viewModel.isBiometricEnabled)
  }

  @Test
  func onAppear_biometricDeclined_biometricIsDisabled() {
    getBiometricStateUseCase.callAsFunctionReturnValue = .declined

    viewModel.onAppear()

    #expect(!viewModel.isBiometricEnabled)
  }

  @Test
  func onAppear_analyticsEnabled_correctState() {
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = true

    viewModel.onAppear()

    #expect(viewModel.isAnalyticsEnabled)
    #expect(!viewModel.isAnalyticsLoading)
  }

  @Test
  func onAppear_analyticsDisabled_correctState() {
    isAnalyticsEnabledUseCase.callAsFunctionReturnValue = false

    viewModel.onAppear()

    #expect(!viewModel.isAnalyticsEnabled)
    #expect(!viewModel.isAnalyticsLoading)
  }

  @Test
  func updateAnalyticsStatus_togglesStatus() async {
    let wasAnalyticsEnabled = viewModel.isAnalyticsEnabled

    await viewModel.updateAnalyticsStatus()

    #expect(updateAnalyticsStatusUseCase.callAsFunctionIsAllowedCallsCount == 1)
    #expect(viewModel.isAnalyticsEnabled == !wasAnalyticsEnabled)
  }

  // MARK: Private

  private let viewModel: SecuritySettingsViewModel
  private let getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy
  private let getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocolSpy
  private let isAnalyticsEnabledUseCase: IsAnalyticsEnabledUseCaseProtocolSpy
  private let updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocolSpy
  private let applicationService: ApplicationServiceProtocolSpy
}
