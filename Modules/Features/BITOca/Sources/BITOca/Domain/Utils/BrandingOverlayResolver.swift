import RegexBuilder
import Spyable

// MARK: - BrandingOverlayResolverProtocol

@Spyable
public protocol BrandingOverlayResolverProtocol {
  func resolve(overlays: [any Overlay]) -> [any Overlay]
}

// MARK: - BrandingOverlayResolver

public class BrandingOverlayResolver: BrandingOverlayResolverProtocol {

  // MARK: Public

  public func resolve(overlays: [any Overlay]) -> [any Overlay] {
    overlays.map { overlay in
      guard var brandingOverlay = overlay as? BrandingOverlay1x1 else {
        return overlay
      }

      brandingOverlay.primaryField = brandingOverlay.resolvePrimaryField { attribute in
        resolveAttributeWithOverlays(brandingOverlay, attribute, overlays)
      }

      brandingOverlay.secondaryField = brandingOverlay.resolveSecondaryField { attribute in
        resolveAttributeWithOverlays(brandingOverlay, attribute, overlays)
      }

      return brandingOverlay
    }
  }

  // MARK: Private

  private static let digestReference = Reference(String?.self)
  private static let keyReference = Reference(String?.self)

  private static let refsRegex = Regex {
    Optionally {
      "refs:"
      Capture(as: digestReference) {
        OneOrMore(CharacterClass(.anyOf("-"), .word))
      } transform: { String($0) }
      ":"
    }
    Capture(as: keyReference) {
      OneOrMore(CharacterClass(.any))
    } transform: { String($0) }
  }

  private func resolveAttributeWithOverlays(_ brandingOverlay: BrandingOverlay1x1, _ attribute: String, _ overlays: [any Overlay]) -> String? {
    let dataSourceOverlays = overlays
      .compactMap { $0 as? any DataSourceOverlay }

    if let (referenceDigest, key) = extractDigestAndKey(attribute) {
      let digest = referenceDigest ?? brandingOverlay.captureBaseDigest
      if let dataSourceOverlay = dataSourceOverlays.first(where: { $0.captureBaseDigest == digest }) {
        return dataSourceOverlay.attributeSources[key]?.rawString
      }
    }
    return attribute
  }

  private func extractDigestAndKey(_ attribute: String) -> (digest: String?, key: String)? {
    guard
      let match = attribute.firstMatch(of: Self.refsRegex),
      let key = match[Self.keyReference]
    else {
      return nil
    }
    return (match[Self.digestReference], key)
  }

}
