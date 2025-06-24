import Foundation
import Spyable

// MARK: - CaptureBaseDisplayGeneratorProtocol

@Spyable
public protocol CaptureBaseDisplayGeneratorProtocol {
  func generate(from ocaBundle: OcaBundle) -> [CaptureBaseDisplay]
}

// MARK: - CaptureBaseDisplayGenerator

public class CaptureBaseDisplayGenerator: CaptureBaseDisplayGeneratorProtocol {

  public func generate(from ocaBundle: OcaBundle) -> [CaptureBaseDisplay] {
    let brandingOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .branding)
      .compactMap { $0 as? BrandingOverlay1x1 }

    let metaOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .meta)
      .compactMap { $0 as? MetaOverlay1x0 }

    let brandingDisplays = brandingOverlays.map { branding in
      let meta = metaOverlays.first { $0.captureBaseDigest == branding.captureBaseDigest && $0.language == branding.language }

      return CaptureBaseDisplay(
        captureBaseDigest: branding.captureBaseDigest,
        language: branding.language,
        theme: branding.theme,
        logo: branding.logo,
        primaryBackgroundColor: branding.primaryBackgroundColor,
        primaryField: branding.primaryField,
        metaName: meta?.name,
        metaDescription: meta?.description)
    }

    let metaOnlyDisplays = metaOverlays
      .filter { metaOverlay in
        brandingOverlays.allSatisfy {
          metaOverlay.captureBaseDigest != $0.captureBaseDigest || metaOverlay.language != $0.language
        }
      }
      .map { meta in
        CaptureBaseDisplay(
          captureBaseDigest: meta.captureBaseDigest,
          language: meta.language,
          metaName: meta.name,
          metaDescription: meta.description)
      }

    return brandingDisplays + metaOnlyDisplays
  }
}
