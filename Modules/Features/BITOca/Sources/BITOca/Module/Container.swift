import BITJsonCanonicalizer
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

  public var ocaBundler: Factory<OcaBundlerProtocol> {
    self { OcaBundler() }
  }

  // MARK: Internal

  var ocaRepository: Factory<OCARepositoryProtocol> {
    self { OCARepository() }
  }

  var jsonCanonicalizer: Factory<JsonCanonicalizerProtocol> {
    self { JsonCanonicalizer() }
  }

  var ocaCESRHashValidator: Factory<OcaCESRHashValidatorProtocol> {
    self { OcaCESRHashValidator() }
  }

  var ocaCaptureBaseDigestsValidator: Factory<OcaCaptureBaseDigestsValidatorProtocol> {
    self { OcaCaptureBaseDigestsValidator() }
  }

  var ocaBundleValidator: Factory<OcaBundleValidatorProtocol> {
    self { OcaBundleValidator() }
  }

  var localeValidator: Factory<LocaleValidatorProtocol> {
    self { LocaleValidator() }
  }
}
