import Factory
import Foundation

extension Container {

  // MARK: Public

  public var settingsRouter: Factory<SettingsRouter> {
    self { SettingsRouter() }
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
    self { ActivityHistorySettingsViewModel() }
  }

  @MainActor
  var licencesViewModel: Factory<LicencesListViewModel> {
    self { LicencesListViewModel() }
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

  // MARK: Internal

  var fetchAnalyticStatusUseCase: Factory<FetchAnalyticStatusUseCaseProtocol> {
    self { FetchAnalyticStatusUseCase() }
  }

}
