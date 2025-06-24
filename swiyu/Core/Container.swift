import Factory
import Foundation

@MainActor
extension Container {
  var splashScreenModule: ParameterFactory<() -> Void, SplashScreenModule> {
    self { SplashScreenModule(completed: $0) }
  }
}

extension Container {

  var userInactivityTimeout: Factory<TimeInterval> { self { 60 * 2 } }

  var splashScreenRouter: Factory<RootRouter> {
    self { RootRouter() }
  }

  var rootRouter: Factory<RootRouter> {
    self { RootRouter() }
  }

  var mamManagedDomain: Factory<String> {
    self { "mam-managed.bit.admin.ch" }
  }

  var trustInfraWildCardDomain: Factory<String> {
    self { "*.trust-infra.swiyu.admin.ch" }
  }

  var trustInfraIntWildCardDomain: Factory<String> {
    self { "*.trust-infra.swiyu-int.admin.ch" }
  }

  var attestationServiceDomain: Factory<String> {
    self { "*.attestations-service.swiyu.admin.ch" }
  }

}
