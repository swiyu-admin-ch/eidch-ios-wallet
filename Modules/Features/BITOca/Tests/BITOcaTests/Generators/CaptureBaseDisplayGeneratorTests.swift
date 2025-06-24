import XCTest
@testable import BITCore
@testable import BITOca

final class CaptureBaseDisplayGeneratorTests: XCTestCase {

  // MARK: Internal

  func testGenerate_MatchingBrandingAndMetaOverlay_returnsCombinedDisplay() throws {
    let branding = try Self.createBrandingOverlay()
    let meta = try Self.createMetaOverlay()
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase()], overlays: [branding, meta])

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 1)
    XCTAssertEqual(displays[0].captureBaseDigest, ocaBundle.rootCaptureBaseDigest)
    XCTAssertEqual(displays[0].language, branding.language)
    XCTAssertEqual(displays[0].theme, Self.mockTheme)
    XCTAssertEqual(displays[0].logo, Self.mockLogo)
    XCTAssertEqual(displays[0].primaryBackgroundColor, Self.mockPrimaryBackgroundColor)
    XCTAssertEqual(displays[0].primaryField, Self.mockPrimaryField)
    XCTAssertEqual(displays[0].metaName, Self.mockName)
    XCTAssertEqual(displays[0].metaDescription, Self.mockDescription)
  }

  func testGenerate_WithOnlyBrandingOverlay_returnDisplayWithoutMetaInfo() throws {
    let branding = try Self.createBrandingOverlay()
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase()], overlays: [branding])

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 1)
    XCTAssertEqual(displays[0].captureBaseDigest, ocaBundle.rootCaptureBaseDigest)
    XCTAssertEqual(displays[0].language, Self.languageMock)
    XCTAssertEqual(displays[0].theme, Self.mockTheme)
    XCTAssertEqual(displays[0].logo, Self.mockLogo)
    XCTAssertEqual(displays[0].primaryBackgroundColor, Self.mockPrimaryBackgroundColor)
    XCTAssertEqual(displays[0].primaryField, Self.mockPrimaryField)
    XCTAssertEqual(displays[0].metaName, nil)
    XCTAssertEqual(displays[0].metaDescription, nil)
  }

  func testGenerate_WithOnlyMetaOverlay_returnDisplayWithoutBrandingInfo() throws {
    let meta = try Self.createMetaOverlay()
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase()], overlays: [meta])

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 1)
    XCTAssertEqual(displays[0].captureBaseDigest, ocaBundle.rootCaptureBaseDigest)
    XCTAssertEqual(displays[0].language, Self.languageMock)
    XCTAssertEqual(displays[0].metaName, Self.mockName)
    XCTAssertEqual(displays[0].metaDescription, Self.mockDescription)
    XCTAssertNil(displays[0].theme)
    XCTAssertNil(displays[0].logo)
    XCTAssertNil(displays[0].primaryBackgroundColor)
    XCTAssertNil(displays[0].primaryField)
  }

  func testGenerate_WithMultipleBrandingAndMeta_returnOnePerLanguage() throws {
    let overlays: [any Overlay] = try [
      Self.createBrandingOverlay(language: "en"),
      Self.createMetaOverlay(language: "en", name: "EN", description: "English"),
      Self.createBrandingOverlay(language: "de", primaryField: "primaryField de"),
      Self.createMetaOverlay(language: "de", name: "DE", description: "Deutsch"),
    ]
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase()], overlays: overlays)

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 2)
    XCTAssertEqual(displays[0].language, "en")
    XCTAssertEqual(displays[0].metaName, "EN")
    XCTAssertEqual(displays[0].primaryField, Self.mockPrimaryField)
    XCTAssertEqual(displays[1].language, "de")
    XCTAssertEqual(displays[1].metaName, "DE")
    XCTAssertEqual(displays[1].primaryField, "primaryField de")
  }

  func testGenerate_MetaAndBrandingMismatchLanguages_returnOnePerLanguage() throws {
    let branding = try Self.createBrandingOverlay(language: "en")
    let meta = try Self.createMetaOverlay(language: "fr", name: "FR", description: "Français")
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase()], overlays: [branding, meta])

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 2)
    XCTAssertEqual(displays[0].language, "en")
    XCTAssertEqual(displays[0].metaName, nil)
    XCTAssertEqual(displays[0].primaryField, Self.mockPrimaryField)
    XCTAssertEqual(displays[1].language, "fr")
    XCTAssertEqual(displays[1].metaName, "FR")
    XCTAssertNil(displays[1].primaryField)
  }

  func testGenerate_MetaAndBrandingMismatch_returnOnePerCaptureBase() throws {
    let otherDigest = "otherDigest"
    let otherCaptureBase = Self.createCaptureBase(digest: otherDigest, attributes: ["captureBase": .reference(digest: Self.digestMock)])
    let branding = try Self.createBrandingOverlay(captureBaseDigest: otherDigest, language: "en")
    let meta = try Self.createMetaOverlay(language: "en", name: "EN", description: "English")
    let ocaBundle = try OcaBundle(captureBases: [Self.createCaptureBase(), otherCaptureBase], overlays: [branding, meta])

    let displays = generator.generate(from: ocaBundle)

    XCTAssertEqual(displays.count, 2)
    XCTAssertEqual(displays[0].captureBaseDigest, otherDigest)
    XCTAssertEqual(displays[0].language, "en")
    XCTAssertEqual(displays[0].metaName, nil)
    XCTAssertEqual(displays[0].primaryField, Self.mockPrimaryField)
    XCTAssertEqual(displays[1].captureBaseDigest, Self.digestMock)
    XCTAssertEqual(displays[1].language, "en")
    XCTAssertEqual(displays[1].metaName, "EN")
    XCTAssertNil(displays[1].primaryField)
  }

  // MARK: Private

  private static let digestMock = "digest"
  private static let languageMock = "en"
  private static let mockTheme = "dark"
  private static let mockLogo = URL(string: "data:image/png;base64,abc")
  private static let mockPrimaryBackgroundColor = "#ffffff"
  private static let mockPrimaryField = "{{primary}}"
  private static let mockName = "name"
  private static let mockDescription = "description"

  private let generator = CaptureBaseDisplayGenerator()

  private static func createCaptureBase(digest: String = digestMock, attributes: [AttributeKey: AttributeType] = [:]) -> CaptureBase1x0 {
    CaptureBase1x0(digest: digest, attributes: attributes, classification: nil, flaggedAttributes: nil)
  }

  private static func createBrandingOverlay(captureBaseDigest: String = digestMock, language: String = languageMock, theme: String? = mockTheme, logo: URL? = mockLogo, primaryBackgroundColor: String? = mockPrimaryBackgroundColor, primaryField: String? = mockPrimaryField) throws -> BrandingOverlay1x1 {
    try BrandingOverlay1x1(captureBaseDigest: captureBaseDigest, logo: logo, primaryBackgroundColor: primaryBackgroundColor, language: language, theme: theme, primaryField: primaryField)
  }

  private static func createMetaOverlay(captureBaseDigest: String = digestMock, language: String = languageMock, name: String = mockName, description: String = mockDescription) throws -> any MetaOverlay {
    MetaOverlay1x0(captureBaseDigest: captureBaseDigest, language: language, name: name, description: description)
  }

}
