import BITJsonCanonicalizer
import Factory
import Foundation

extension Container {

  // MARK: Public

  public var ocaBundleService: Factory<OCABundleServiceProtocol> {
    self { OCABundleService() }
  }

  public var ocaBundler: Factory<OcaBundlerProtocol> {
    self { OcaBundler() }
  }

  public var captureBaseDisplayGenerator: Factory<CaptureBaseDisplayGeneratorProtocol> {
    self { CaptureBaseDisplayGenerator() }
  }

  public var ocaRepository: Factory<OCARepositoryProtocol> {
    self { OCARepository() }
  }

  // MARK: Internal

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

  var brandingOverlayResolver: Factory<BrandingOverlayResolverProtocol> {
    self { BrandingOverlayResolver() }
  }

  var rootCaptureBaseResolver: Factory<RootCaptureBaseResolverProtocol> {
    self { RootCaptureBaseResolver() }
  }

  var localeValidator: Factory<LocaleValidatorProtocol> {
    self { LocaleValidator() }
  }

  var overlayBundleAttributesGenerator: Factory<OverlayBundleAttributesGeneratorProtocol> {
    self { OverlayBundleAttributesGenerator() }
  }

}
