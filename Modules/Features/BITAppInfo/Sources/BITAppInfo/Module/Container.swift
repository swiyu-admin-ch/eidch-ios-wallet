import BITCore
import Factory
import Foundation

extension Container {

  // MARK: Public

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
      guard let url = URL(string: "https://versioning.trust-infra.swiyu.admin.ch/api/versioning?platform=ios&app_id=wallet") else {
        fatalError("No valid URL for version enforcement")
      }
      return url
    }
  }

  public var appIdentifierRepository: Factory<AppIdentifierRepositoryProtocol> {
    self { AppIdentifierRepository() }
  }

  public var swissProfileLifecycleRepository: Factory<SwissProfileLifecycleRepositoryProtocol> {
    self { self.enforcementRepository() }
  }

  // MARK: Internal

  var versionEnforcementRepository: Factory<VersionEnforcementRepositoryProtocol> {
    self { self.enforcementRepository() }
  }

  var versionEnforcementCache: Factory<CacheManager<VersionEnforcement.Response>> {
    self { CacheManager() }
  }

  var deviceInfoProvider: Factory<DeviceInfoProviderProtocol> {
    self { DeviceInfoProvider() }
  }

  // MARK: Private

  private var enforcementRepository: Factory<VersionEnforcementRepository> {
    self { VersionEnforcementRepository() }.singleton
  }
}

@MainActor
extension Container {

  @MainActor
  var versionEnforcementModule: ParameterFactory<(VersionEnforcement, VersionEnforcementDelegate), VersionEnforcementModule> {
    self { @MainActor in VersionEnforcementModule(versionEnforcement: $0, delegate: $1) }
  }

  @MainActor
  var versionEnforcementViewModel: ParameterFactory<(VersionEnforcementRouterRoutes, VersionEnforcement, VersionEnforcementDelegate), VersionEnforcementViewModel> {
    self { @MainActor in VersionEnforcementViewModel(router: $0, versionEnforcement: $1, delegate: $2) }
  }
}
