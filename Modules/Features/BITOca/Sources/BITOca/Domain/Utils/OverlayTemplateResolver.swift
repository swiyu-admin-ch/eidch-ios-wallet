import BITClaimsPathPointer
import Factory
import RegexBuilder
import Spyable

// MARK: - OverlayTemplateResolverProtocol

@Spyable
public protocol OverlayTemplateResolverProtocol {
  func callAsFunction(overlays: [any Overlay]) -> [any Overlay]
}

// MARK: - OverlayTemplateResolver

class OverlayTemplateResolver: OverlayTemplateResolverProtocol {

  // MARK: Internal

  func callAsFunction(overlays: [any Overlay]) -> [any Overlay] {
    overlays.map { overlay in
      switch overlay {
      case let brandingOverlay as BrandingOverlay1x1:
        resolveBrandingOverlay(overlay: brandingOverlay, overlays: overlays)
      case let labelOverlay as LabelOverlay1x1:
        resolveLabelOverlay(overlay: labelOverlay, overlays: overlays)
      default: overlay
      }
    }
  }

  // MARK: Private

  @Injected(\.attributeTemplateResolver) private var attributeTemplateResolver

  private func resolveBrandingOverlay(overlay: BrandingOverlay1x1, overlays: [any Overlay]) -> BrandingOverlay1x1 {
    var resolved = overlay
    if let primaryField = overlay.primaryField {
      resolved.primaryField = attributeTemplateResolver(primaryField, digest: overlay.captureBaseDigest, overlays: overlays)
    }
    if let secondaryField = overlay.secondaryField {
      resolved.secondaryField = attributeTemplateResolver(secondaryField, digest: overlay.captureBaseDigest, overlays: overlays)
    }
    return resolved
  }

  private func resolveLabelOverlay(overlay: LabelOverlay1x1, overlays: [any Overlay]) -> LabelOverlay1x1 {
    var resolved = overlay
    resolved.attributeLabels = overlay.attributeLabels.mapValues { value in
      attributeTemplateResolver(value, digest: overlay.captureBaseDigest, overlays: overlays)
    }
    return resolved
  }
}
