import Factory
import Foundation

extension Container {

  // MARK: Public

  public var isOCABundleFetchFeatureEnabled: Factory<Bool> {
    self { false }
  }

  public var ocaBundleService: Factory<OCABundleServiceProtocol> {
    self { OCABundleService() }
  }

  // MARK: Internal

  var ocaRepository: Factory<OCARepositoryProtocol> {
    self { OCARepository() }
  }

}
