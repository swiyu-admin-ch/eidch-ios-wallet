// swiftlint: disable force_try implicitly_unwrapped_optional
import Factory
import Spyable
import Testing
@testable import BITClaimsPathPointer
@testable import BITOca

struct OverlayTemplateResolverTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let attributeResolverSpy = AttributeTemplateResolverProtocolSpy()
    self.attributeResolverSpy = attributeResolverSpy
    Container.shared.attributeTemplateResolver.register { attributeResolverSpy }

    resolver = OverlayTemplateResolver()

    createSuccessState()
  }

  // MARK: Internal

  @Test
  func resolve_brandingOverlay_returnsResolvedBrandingOverlay() {
    let result = resolver(overlays: [brandingOverlayMock])

    #expect(result.count == 1)
    #expect(result.first as? BrandingOverlay1x1 == expectedBrandingOverlay)
  }

  @Test
  func resolve_labelOverlay_returnsResolvedLabelOverlay() {
    let result = resolver(overlays: [labelOverlayMock])

    #expect(result.count == 1)
    #expect(result.first as? LabelOverlay1x1 == expectedLabelOverlay)
  }

  @Test
  func resolve_multipleOverlaysToResolve_returnsOverlaysResolved() {
    let result = resolver(overlays: [labelOverlayMock, brandingOverlayMock, labelOverlay1x0Mock])

    #expect(result.count == 3)

    let labelOverlay = result.first(where: { $0 is LabelOverlay1x1 })
    #expect(labelOverlay as? LabelOverlay1x1 == expectedLabelOverlay)

    let brandingOverlay = result.first(where: { $0 is BrandingOverlay1x1 })
    #expect(brandingOverlay as? BrandingOverlay1x1 == expectedBrandingOverlay)

    let labelOverlay1x0 = result.first(where: { $0 is LabelOverlay1x0 })
    #expect(labelOverlay1x0 as? LabelOverlay1x0 == labelOverlay1x0Mock)
  }

  @Test
  func resolve_otherOverlays_returnsOtherOverlays() {
    let result = resolver(overlays: [labelOverlay1x0Mock])

    #expect(result.count == 1)
    #expect(result.first as? LabelOverlay1x0 == labelOverlay1x0Mock)
  }

  @Test
  func resolve_emptyOverlays_returnsEmpty() {
    let result = resolver(overlays: [])

    #expect(result.isEmpty)
  }

  // MARK: Private

  private static let digestMock = "digest"
  private static let languageMock = "language"
  private static let key1 = "key1"
  private static let key2 = "key2"
  private static let attribute1 = "attribute1"
  private static let attribute2 = "attribute2"
  private static let attribute1Resolved = "attribute1Resolved"
  private static let attribute2Resolved = "attribute2Resolved"

  private static let attributeLabels = [key1: attribute1, key2: attribute2]

  private static let attributeLabelsResolved = [key1: attribute1Resolved, key2: attribute2Resolved]

  private let brandingOverlayMock = try! BrandingOverlay1x1(
    captureBaseDigest: digestMock,
    logo: nil,
    language: languageMock,
    primaryField: attribute1,
    secondaryField: attribute2)

  private let expectedBrandingOverlay = try! BrandingOverlay1x1(
    captureBaseDigest: digestMock,
    logo: nil,
    language: languageMock,
    primaryField: attribute1Resolved,
    secondaryField: attribute2Resolved)

  private let labelOverlayMock = LabelOverlay1x1(
    captureBaseDigest: digestMock,
    language: languageMock,
    attributeLabels: attributeLabels,
    attributeCategories: nil,
    categoryLabels: nil)

  private let expectedLabelOverlay = LabelOverlay1x1(
    captureBaseDigest: digestMock,
    language: languageMock,
    attributeLabels: attributeLabelsResolved,
    attributeCategories: nil,
    categoryLabels: nil)

  private let labelOverlay1x0Mock = LabelOverlay1x0(
    captureBaseDigest: digestMock,
    language: languageMock,
    attributeLabels: attributeLabels,
    attributeCategories: nil,
    categoryLabels: nil)

  private var attributeResolverSpy: AttributeTemplateResolverProtocolSpy!

  private let resolver: OverlayTemplateResolver!

  private func createSuccessState() {
    attributeResolverSpy.callAsFunctionDigestOverlaysClosure = { attribute, _, _ in
      switch attribute {
      case Self.attribute1:
        Self.attribute1Resolved
      case Self.attribute2:
        Self.attribute2Resolved
      default:
        attribute
      }
    }
  }
}
