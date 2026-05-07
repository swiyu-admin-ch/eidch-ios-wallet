import XCTest
@testable import BITClaimsPathPointer
@testable import BITOca

final class BrandingOverlayResolverTests: XCTestCase {

  // MARK: Internal

  func testResolve_attributesInDataSource_resolves() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay()
    let brandingOverlay = try Self.createBrandingOverlay()

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings.first?.primaryField, "Firstname: {{[\"firstname\"]}}")
    XCTAssertEqual(resolvedBrandings.first?.secondaryField, "Lastname: {{[\"lastname\"]}}")
  }

  func testResolve_attributesNotInDataSource_isRemoved() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay(attributeSources: [:])
    let brandingOverlay = try Self.createBrandingOverlay()

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings.first?.primaryField, "Firstname: ")
    XCTAssertEqual(resolvedBrandings.first?.secondaryField, "Lastname: ")
  }

  func testResolve_EmptyOverlays_ReturnsEmpty() {
    let overlays = resolver.resolve(overlays: [])

    XCTAssert(overlays.isEmpty)
  }

  func testResolve_digestNotFound_returnsUnresolved() throws {
    let unresolvedPrimary = "Firstname: {{refs:otherDigest:firstname}}"
    let unresolvedSecondary = "Lastname: {{refs:otherDigest:lastname}}"
    let dataSourceOverlay = Self.createDataSourceOverlay(digest: "a")
    let brandingOverlay = try Self.createBrandingOverlay(digest: "b", primaryField: unresolvedPrimary, secondaryField: unresolvedSecondary)

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings[0].primaryField, unresolvedPrimary)
    XCTAssertEqual(resolvedBrandings[0].secondaryField, unresolvedSecondary)
  }

  func testResolve_multipleAttributes_resolvesMultipleAttributes() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay()
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: "Fullname: {{firstname}} {{lastname}}", secondaryField: "Location: {{city}}, {{country}}")

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings[0].primaryField, "Fullname: {{[\"firstname\"]}} {{[\"lastname\"]}}")
    XCTAssertEqual(resolvedBrandings[0].secondaryField, "Location: {{[\"city\"]}}, {{[\"country\"]}}")
  }

  func testResolve_attributesInDifferentDataSources_resolves() throws {
    let dataSourceOverlayA = Self.createDataSourceOverlay(digest: "A", attributeSources: ["firstname": [ .string("firstname")]])
    let dataSourceOverlayB = Self.createDataSourceOverlay(digest: "B", attributeSources: ["lastname": [.string("lastname")]])
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: "Fullname: {{refs:A:firstname}} {{refs:B:lastname}}")

    let overlays = resolver.resolve(overlays: [dataSourceOverlayA, dataSourceOverlayB, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings[0].primaryField, "Fullname: {{[\"firstname\"]}} {{[\"lastname\"]}}")
  }

  func testResolve_dataSource1x0_resolves() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay1x0()
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: "Firstname: {{firstname}}")

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings.first?.primaryField, "Firstname: {{[\"firstname\"]}}")
  }

  func testResolve_multipleDataSourceVersions_resolvesLatest() throws {
    let oldDataSourceOverlay = Self.createDataSourceOverlay1x0(attributeSources: ["firstname": [.string("otherFirstName")]])
    let dataSourceOverlay = Self.createDataSourceOverlay()
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: "Firstname: {{firstname}}")

    let overlays = resolver.resolve(overlays: [oldDataSourceOverlay, dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings.first?.primaryField, "Firstname: {{[\"firstname\"]}}")
  }

  func testResolve_noMatchingDataSource_returnsOriginal() throws {
    let brandingOverlay = try Self.createBrandingOverlay()
    let dataSourceOverlay = Self.createDataSourceOverlay(digest: "otherDigest")

    let overlays = resolver.resolve(overlays: [brandingOverlay, dataSourceOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings[0].primaryField, "Firstname: {{refs:digest:firstname}}")
    XCTAssertEqual(resolvedBrandings[0].secondaryField, "Lastname: {{refs:digest:lastname}}")
  }

  func testResolve_AttributeMismatch_returnsUnresolved() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay()
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: "Firstname: {{firstnam}}", secondaryField: "Lastname: {{astname}}")

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertEqual(resolvedBrandings[0].primaryField, "Firstname: ")
    XCTAssertEqual(resolvedBrandings[0].secondaryField, "Lastname: ")
  }

  func testResolve_nilField_resolvesToNil() throws {
    let dataSourceOverlay = Self.createDataSourceOverlay()
    let brandingOverlay = try Self.createBrandingOverlay(primaryField: nil, secondaryField: nil)

    let overlays = resolver.resolve(overlays: [dataSourceOverlay, brandingOverlay])
    let resolvedBrandings = overlays.compactMap { $0 as? BrandingOverlay1x1 }

    XCTAssertNil(resolvedBrandings[0].primaryField)
    XCTAssertNil(resolvedBrandings[0].secondaryField)
  }

  // MARK: Private

  // swiftlint: disable force_try

  private static let digestMock = "digest"
  private static let formatMock = "vc"
  private static let languageMock = "en"

  private static let primaryFieldWithReference = "Firstname: {{refs:digest:firstname}}"
  private static let secondaryFieldWithReference = "Lastname: {{refs:digest:lastname}}"

  private static let attributeSources: [String: ClaimsPathPointer] = [
    "firstname": [.string("firstname")],
    "lastname": [.string("lastname")],
    "city": [.string("city")],
    "country": [.string("country")],
  ]

  private var resolver = BrandingOverlayResolver()

  private static func createCaptureBase(digest: String = digestMock, attributes: [AttributeKey: AttributeType] = [:]) -> CaptureBase1x0 {
    CaptureBase1x0(digest: digest, attributes: attributes, classification: nil, flaggedAttributes: nil)
  }

  private static func createDataSourceOverlay1x0(digest: String = digestMock, format: String = formatMock, attributeSources: [AttributeKey: ClaimsPathPointer] = attributeSources) -> DataSourceOverlay1x0 {
    DataSourceOverlay1x0(captureBaseDigest: digest, format: format, attributeSources: attributeSources)
  }

  private static func createDataSourceOverlay(digest: String = digestMock, format: String = formatMock, attributeSources: [AttributeKey: ClaimsPathPointer] = attributeSources) -> DataSourceOverlay2x0 {
    DataSourceOverlay2x0(captureBaseDigest: digest, format: format, attributeSources: attributeSources)
  }

  private static func createBrandingOverlay(digest: String = digestMock, language: String = languageMock, primaryField: String? = primaryFieldWithReference, secondaryField: String? = secondaryFieldWithReference) throws -> BrandingOverlay1x1 {
    try BrandingOverlay1x1(captureBaseDigest: digest, logo: nil, language: language, primaryField: primaryField, secondaryField: secondaryField)
  }

  // swiftlint: enable force_try
}
