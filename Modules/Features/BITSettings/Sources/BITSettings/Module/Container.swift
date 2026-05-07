import Factory
import Foundation

extension Container {

  // MARK: Public

  public var isOTPDebugToggleEnabled: Factory<Bool> {
    self { false }
  }

  // MARK: Internal

  var settingsViewModel: Factory<SettingsViewModel> {
    self { SettingsViewModel() }
  }

  var securitySettingsViewModel: Factory<SecuritySettingsViewModel> {
    self { SecuritySettingsViewModel() }
  }

  @MainActor
  var activityHistorySettingsViewModel: Factory<ActivityHistorySettingsViewModel> {
    self { @MainActor in ActivityHistorySettingsViewModel(getActivityHistoryEnabledSubject: self.getActivityHistoryEnabledSubjectUseCase()) }
  }

  @MainActor
  var licencesViewModel: Factory<LicencesListViewModel> {
    self { @MainActor in LicencesListViewModel() }
  }
}

extension Container {

  // MARK: Public

  public var fetchPackagesUseCase: Factory<FetchPackagesUseCaseProtocol> {
    self { FetchPackagesUseCase(filePath: "package-list") }
  }

  public var analyticsRepository: Factory<AnalyticsRepositoryProtocol> {
    self { AnalyticsRepository() }
  }

  public var updateAnalyticsStatusUseCase: Factory<UpdateAnalyticStatusUseCaseProtocol> {
    self { UpdateAnalyticStatusUseCase() }
  }

  public var isLottieViewerEnabled: Factory<Bool> {
    self { false }
  }

  // MARK: Internal

  var fetchAnalyticStatusUseCase: Factory<FetchAnalyticStatusUseCaseProtocol> {
    self { FetchAnalyticStatusUseCase() }
  }

}
