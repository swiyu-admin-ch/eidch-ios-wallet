import Factory
import Foundation

extension Container {

  public var getAppVersionUseCase: Factory<GetAppVersionUseCaseProtocol> {
    self { GetAppVersionUseCase() }
  }

  public var getBuildNumberUseCase: Factory<GetBuildNumberUseCaseProtocol> {
    self { GetBuildNumberUseCase() }
  }

  public var appVersionRepository: Factory<AppVersionRepositoryProtocol> {
    self { BundleAppVersionRepository() }
  }

  public var fetchVersionEnforcementUseCase: Factory<FetchVersionEnforcementUseCaseProtocol> {
    self { FetchVersionEnforcementUseCase() }
  }

  public var versionEnforcementRouter: Factory<VersionEnforcementRouter> {
    self { VersionEnforcementRouter() }
  }

  public var versionEnforcementLoginTimeout: Factory<UInt64> {
    self { 1_000_000_000 }
  }

  public var versionEnforcementUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://wallet-ve.trust-infra.swiyu.admin.ch/v1/ios") else {
        fatalError("No valid URL for version enforcement")
      }
      return url
    }
  }

  public var versionEnforcementRepository: Factory<VersionEnforcementRepositoryProtocol> {
    self { VersionEnforcementRepository() }
  }

  public var appIdentifierRepository: Factory<AppIdentifierRepositoryProtocol> {
    self { AppIdentifierRepository() }
  }
}

@MainActor
extension Container {

  @MainActor
  var versionEnforcementModule: ParameterFactory<VersionEnforcement, VersionEnforcementModule> {
    self { @MainActor in VersionEnforcementModule(versionEnforcement: $0) }
  }

  @MainActor
  var versionEnforcementViewModel: ParameterFactory<(VersionEnforcementRouterRoutes, VersionEnforcement), VersionEnforcementViewModel> {
    self { @MainActor in VersionEnforcementViewModel(router: $0, versionEnforcement: $1) }
  }
}
