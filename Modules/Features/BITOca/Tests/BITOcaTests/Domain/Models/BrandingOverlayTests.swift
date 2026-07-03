import Foundation
import Testing
@testable import BITOca

struct BrandingOverlayTests {

  // MARK: Internal

  @Test
  func init_validLogo_returnsOverlay() throws {
    let result = try BrandingOverlay1x1(captureBaseDigest: "abc", logo: Self.validDataUrl, language: "en")

    #expect(result.logo == Self.validDataUrl)
  }

  @Test
  func init_invalidLogo_throwsInvalidDataURIError() {
    #expect(throws: OcaError.invalidOverlayDataURI) {
      try BrandingOverlay1x1(captureBaseDigest: "abc", logo: Self.invalidDataUrl, language: "en")
    }
  }

  @Test
  func init_validBackgroundImage_returnsOverlay() throws {
    let result = try BrandingOverlay1x1(captureBaseDigest: "abc", backgroundImage: Self.validDataUrl, language: "en")

    #expect(result.backgroundImage == Self.validDataUrl)
  }

  @Test
  func init_invalidBackgroundImage_throwsInvalidDataURIError() {
    #expect(throws: OcaError.invalidOverlayDataURI) {
      try BrandingOverlay1x1(captureBaseDigest: "abc", backgroundImage: Self.invalidDataUrl, language: "en")
    }
  }

  // MARK: Private

  private static let validDataUrl = URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA")
  private static let invalidDataUrl = URL(string: "malformed")
}
