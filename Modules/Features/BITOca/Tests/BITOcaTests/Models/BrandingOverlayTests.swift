import XCTest
@testable import BITOca

final class BrandingOverlayTests: XCTestCase {

  // MARK: Internal

  func testResolvePrimaryField_oneTemplate_returnsResolvedOverlay() throws {
    let overlay = try createBrandingOverlay(primaryField: "Name: {{firstname}}")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Name: {{$.firstname}}")
  }

  func testResolvePrimaryField_multiTemplate_returnsResolvedOverlay() throws {
    let overlay = try createBrandingOverlay(primaryField: "Name: {{firstname}} {{lastname}}")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Name: {{$.firstname}} {{$.lastname}}")
  }

  func testResolvePrimaryField_Unknown_returnsEmpty() throws {
    let overlay = try createBrandingOverlay(primaryField: "Name: {{unknown}}")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Name: ")
  }

  func testResolvePrimaryField_KnownAndUnknown_returnsEmpty() throws {
    let overlay = try createBrandingOverlay(primaryField: "Name: {{firstname}} {{unknown}}")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Name: {{$.firstname}} ")
  }

  func testResolvePrimaryField_Malformed_returnsAsIs() throws {
    let overlay = try createBrandingOverlay(primaryField: "Value: {{firstname")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Value: {{firstname")
  }

  func testResolvePrimaryField_noPlaceholder_returnsAsIs() throws {
    let overlay = try createBrandingOverlay(primaryField: "Label")
    XCTAssertEqual(overlay.resolvePrimaryField { Self.mockSource[$0] }, "Label")
  }

  func testResolvePrimaryField_nil_returnsNil() throws {
    let overlay = try createBrandingOverlay(primaryField: nil)
    XCTAssertNil(overlay.resolvePrimaryField { Self.mockSource[$0] })
  }

  func testValidate_invalidLogo_throwsInvalidDataURIError() throws {
    XCTAssertThrowsError(try BrandingOverlay1x1(captureBaseDigest: "abc", logo: URL(string: "malformed"), language: "en")) { error in
      XCTAssertEqual(error as? OcaError, .invalidOverlayDataURI)
    }
  }

  func testValidate_invalidBackgroundImage_throwsInvalidDataURIError() throws {
    XCTAssertThrowsError(try BrandingOverlay1x1(captureBaseDigest: "abc", backgroundImage: URL(string: "malformed"), language: "en")) { error in
      XCTAssertEqual(error as? OcaError, .invalidOverlayDataURI)
    }
  }

  // MARK: Private

  private static let mockSource = ["firstname": "$.firstname", "lastname": "$.lastname"]

  private func createBrandingOverlay(primaryField: String?) throws -> BrandingOverlay1x1 {
    try BrandingOverlay1x1(captureBaseDigest: "abc", language: "en", primaryField: primaryField)
  }

}
