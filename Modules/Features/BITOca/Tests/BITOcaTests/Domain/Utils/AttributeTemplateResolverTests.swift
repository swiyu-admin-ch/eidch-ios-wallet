import Testing
@testable import BITClaimsPathPointer
@testable import BITOca

struct AttributeTemplateResolverTests {

  // MARK: Internal

  @Test(arguments: [
    attribute1Template,
    attribute1TemplateWithDigest,
  ])
  func resolve_validTemplate_returnsResolvedPath(attribute: String) {
    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayMock])

    #expect(result == "Test: {{[\"\(Self.attribute1)\"]}}")
  }

  @Test
  func resolve_validMultiTemplate_returnsResolvedPaths() {
    let attribute = "Test: {{\(Self.attribute1)}} {{\(Self.attribute2)}}"

    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayMock])

    #expect(result == "Test: {{[\"\(Self.attribute1)\"]}} {{[\"\(Self.attribute2)\"]}}")
  }

  @Test
  func resolve_validIndexTemplate_returnsResolvedPaths() {
    let attribute = "Test: {{\(Self.attribute1)[0]}}"

    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayArrayMock])

    #expect(result == "Test: {{[\"\(Self.attribute1)\",0]}}")
  }

  @Test
  func resolve_validNullTemplate_returnsResolvedPaths() {
    let attribute = "Test: {{\(Self.attribute1)[null]}}"

    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayArrayMock])

    #expect(result == "Test: {{[\"\(Self.attribute1)\",null]}}")
  }

  @Test(arguments: [
    ("Test: {{\(attribute1)[null]", ".join(',')"),
    ("Test: {{\(attribute1)[null]", ".join(\",\")"),
    ("Test: {{\(attribute1)[null]", ".join('')"),
    ("Test: {{\(attribute1)[null]", ".join('1234567890')")
  ])
  func resolve_validJoinTemplate_returnsResolvedPaths(attribute: String, join: String) {
    let result = resolver(attribute + join + "}}", digest: Self.digestMock, overlays: [dataSourceOverlayArrayMock])

    #expect(result == "Test: {{[\"\(Self.attribute1)\",null]\(join)}}")
  }

  @Test
  func resolve_attributesAcrossDifferentDataSources_returnsResolvedPaths() {
    let attribute = "Test: {{\(Self.attribute1)}} {{refs:\(Self.otherDigestMock):\(Self.attribute2)}}"
    let dataSourceOverlay1 = Self.createDataSourceOverlay(
      digest: Self.digestMock,
      attributeSources: [Self.attribute1: Self.attribute1Path])
    let dataSourceOverlay2 = Self.createDataSourceOverlay(
      digest: Self.otherDigestMock,
      attributeSources: [Self.attribute2: Self.attribute2Path])

    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlay1, dataSourceOverlay2])

    #expect(result == "Test: {{[\"\(Self.attribute1)\"]}} {{[\"\(Self.attribute2)\"]}}")
  }

  @Test
  func resolve_dataSource1x0_returnsResolvedPaths() {
    let dataSourceOverlay = createDataSourceOverlay1x0()

    let result = resolver(Self.attribute1Template, digest: Self.digestMock, overlays: [dataSourceOverlay])

    #expect(result == Self.attribute1Resolved)
  }

  @Test
  func resolve_multipleDataSourceVersions_returnsResolvedPathsFromLatest() {
    let dataSourceOverlay1x0 = createDataSourceOverlay1x0()
    let dataSourceOverlay2x0 = Self.createDataSourceOverlay(attributeSources: [Self.attribute1: Self.attribute2Path])

    let result = resolver(Self.attribute1Template, digest: Self.digestMock, overlays: [dataSourceOverlay1x0, dataSourceOverlay2x0])

    #expect(result == "Test: {{[\"\(Self.attribute2)\"]}}")
  }

  @Test(arguments: [
    "\(attribute1)",
    "{{\(attribute1)",
    "{{\(attribute1)}",
    "\(attribute1)}}",
    "{\(attribute1)}}",
  ])
  func resolve_noTemplate_returnsAsIs(attribute: String) {
    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayMock])

    #expect(result == attribute)
  }

  @Test(arguments: [
    "Test: {{}}",
    "Test: {{ref}}",
    "Test: {{:attribute}}",
    "Test: {{invalidRef:digest:attribute}}",
    "Test: {{refs::digest:attribute}}",
    "Test: {{refs::digest::attribute}}",
    "Test: {{refs::digest:attribute[\"name\"]}}",
    "Test: {{refs::digest:attribute['name']}}",
    "Test: {{refs::digest:attribute[null].join(' ')}}",
    "Test: {{refs:digest::attribute[null].join(' ')}}",
    "Test: {{refs::digest:attribute[null]..join(' ')}}",
    "Test: {{refs:digest:attribute[null].join( )}}",
    "Test: {{refs:digest:attribute[null].join(' )}}",
    "Test: {{refs:digest:attribute[null].join( ')}}",
    "Test: {{refs:digest:attribute[null].join(\" )}}",
    "Test: {{refs:digest:attribute[null].join( \")}}",
    "Test: {{refs:digest:attribute[null].join(' \")}}",
    "Test: {{refs:digest:attribute[null].join(\" ')}}",
    "Test: {{refs:digest:attribute[null].join('moreThan10Chars')}}",
    "Test: {{Test: {{\(attribute1)}}}}",
  ])
  func resolve_invalidTemplate_returnsUnresolved(attribute: String) {
    let result = resolver(attribute, digest: Self.digestMock, overlays: [dataSourceOverlayMock])

    #expect(result == Self.unresolved)
  }

  @Test
  func resolve_emptyOverlays_returnsUnresolved() {
    let result = resolver(Self.attribute1Template, digest: Self.digestMock, overlays: [])

    #expect(result == Self.unresolved)
  }

  @Test
  func resolve_noMatchingDataSource_returnsUnresolved() {
    let dataSourceOverlay = Self.createDataSourceOverlay(digest: Self.otherDigestMock)

    let result = resolver(Self.attribute1Template, digest: Self.digestMock, overlays: [dataSourceOverlay])

    #expect(result == Self.unresolved)
  }

  @Test
  func resolve_digestNotFound_returnsUnresolved() {
    let dataSourceOverlay = Self.createDataSourceOverlay(digest: Self.otherDigestMock)

    let result = resolver(Self.attribute1Template, digest: Self.digestMock, overlays: [dataSourceOverlay])

    #expect(result == Self.unresolved)
  }

  // MARK: Private

  private static let digestMock = "digest"
  private static let otherDigestMock = "otherDigest"
  private static let formatMock = "vc"
  private static let attribute1 = "attribute1"
  private static let attribute2 = "attribute2"
  private static let attribute1Path: ClaimsPathPointer = [.string("attribute1")]
  private static let attribute1ArrayPath: ClaimsPathPointer = [.string("attribute1"), .null]
  private static let attribute2Path: ClaimsPathPointer = [.string("attribute2")]

  private static let attribute1Template = "Test: {{\(attribute1)}}"
  private static let attribute1TemplateWithDigest = "Test: {{refs:\(digestMock):\(attribute1)}}"
  private static let unresolved = "Test: "
  private static let attribute1Resolved = "Test: {{[\"\(attribute1)\"]}}"

  private static let defaultAttributeSources: [AttributeKey: ClaimsPathPointer] = [
    attribute1: attribute1Path,
    attribute2: attribute2Path,
  ]

  private var dataSourceOverlayMock = createDataSourceOverlay()
  private var dataSourceOverlayArrayMock = createDataSourceOverlay(attributeSources: [attribute1: attribute1ArrayPath])

  private let resolver = AttributeTemplateResolver()

  private static func createDataSourceOverlay(
    digest: String = digestMock,
    format: String = formatMock,
    attributeSources: [AttributeKey: ClaimsPathPointer] = defaultAttributeSources)
    -> DataSourceOverlay2x0
  {
    DataSourceOverlay2x0(
      captureBaseDigest: digest,
      format: format,
      attributeSources: attributeSources)
  }

  private func createDataSourceOverlay1x0() -> DataSourceOverlay1x0 {
    DataSourceOverlay1x0(
      captureBaseDigest: Self.digestMock,
      format: Self.formatMock,
      attributeSources: Self.defaultAttributeSources)
  }

}
