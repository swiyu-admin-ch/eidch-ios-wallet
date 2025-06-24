import XCTest
@testable import BITOca

// swiftlint:disable force_unwrapping

// MARK: - OverlayBundleAttributesGeneratorTests

final class OverlayBundleAttributesGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    generator = OverlayBundleAttributesGenerator()
  }

  func testGenerate_noOverlays_returnsAttributeWithOnlyRequiredFields() throws {
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attributes = generator.generate(from: ocaBundle)

    XCTAssertEqual(attributes.count, 2)
    let attribute = attributes.first { $0.name == Self.attributeMock }!
    XCTAssertEqual(attribute.captureBaseDigest, Self.rootCaptureBaseDigest)
    XCTAssertEqual(attribute.name, Self.attributeMock)
    XCTAssertEqual(attribute.attributeType, Self.attributeTypeMock)
    XCTAssertNil(attribute.characterEncoding)
    XCTAssertTrue(attribute.dataSources.isEmpty)
    XCTAssertNil(attribute.format)
    XCTAssertTrue(attribute.labels.isEmpty)
    XCTAssertNil(attribute.order)
    XCTAssertNil(attribute.standard)
  }

  func testGenerate_encodingNoDefault_returnsAttributeWithEncoding() throws {
    let overlay = CharacterEncodingOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, defaultCharacterEncoding: nil, attributeCharacterEncodings: [Self.attributeMock: .base64])
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [overlay])

    let attributes = generator.generate(from: ocaBundle)

    XCTAssertEqual(attributes.count, 2)
    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.characterEncoding, .base64)
    XCTAssertNil(otherAttribute.characterEncoding)
  }

  func testGenerate_encodingDefault_returnsAttributeWithEncoding() throws {
    let overlay = CharacterEncodingOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, defaultCharacterEncoding: .base64, attributeCharacterEncodings: [Self.attributeMock: .unknown(rawString: "encoding")])
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [overlay])

    let attributes = generator.generate(from: ocaBundle)

    XCTAssertEqual(attributes.count, 2)
    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.characterEncoding, .unknown(rawString: "encoding"))
    XCTAssertEqual(otherAttribute.characterEncoding, .base64)
  }

  func testGenerate_dateSources_returnsAttributeWithDataSources() throws {
    let dataSources = try ["format1": JsonPath(rawString: "$.format1JsonPath"), "format2": JsonPath(rawString: "$.format2JsonPath")]
    let overlays = createDataSourceOverlays(for: dataSources)
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: overlays)

    let attributes = generator.generate(from: ocaBundle)

    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.dataSources, dataSources)
    XCTAssertTrue(otherAttribute.dataSources.isEmpty)
  }

  func testGenerate_format_returnsAttributeWithFormat() throws {
    let overlay = FormatOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, attributeFormats: [Self.attributeMock: "format"])
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [overlay])

    let attributes = generator.generate(from: ocaBundle)

    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.format, "format")
    XCTAssertNil(otherAttribute.format)
  }

  func testGenerate_labels_returnsAttributeWithLabels() throws {
    let labels = ["en": "label_en", "de": "label_de"]
    let overlays = createLabelOverlays(for: labels)
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: overlays)

    let attributes = generator.generate(from: ocaBundle)

    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.labels, labels)
    XCTAssertTrue(otherAttribute.labels.isEmpty)
  }

  func testGenerate_order_returnsAttributeWithOrder() throws {
    let overlay = OrderOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, attributeOrders: [Self.attributeMock: 1])
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [overlay])

    let attributes = generator.generate(from: ocaBundle)

    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.order, 1)
    XCTAssertNil(otherAttribute.order)
  }

  func testGenerate_standard_returnsAttributeWithStandard() throws {
    let overlay = StandardOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, attributeStandards: [Self.attributeMock: .dataURLScheme])
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [overlay])

    let attributes = generator.generate(from: ocaBundle)

    let attribute = attributes.first { $0.name == Self.attributeMock }!
    let otherAttribute = attributes.first { $0.name == Self.otherAttributeMock }!
    XCTAssertEqual(attribute.standard, .dataURLScheme)
    XCTAssertNil(otherAttribute.standard)
  }

  func testGenerate_nested_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attributes = generator.generate(from: ocaBundle)

    XCTAssertEqual(attributes.count, 11)
    let rootBaseAttributes = attributes.filter { $0.captureBaseDigest == "IK4ceQ-qvbporNvdFExEAMQrPud9OutHQbB2pc2iXrvW" }
    XCTAssertEqual(rootBaseAttributes.count, 3)

    let captureBase1Attributes = attributes.filter { $0.captureBaseDigest == "IACad8m8doJZoyOwmkcSOGD0OKL6JoNtC22I1K4DlFMh" }
    XCTAssertEqual(captureBase1Attributes.count, 3)

    let captureBase2Attributes = attributes.filter { $0.captureBaseDigest == "IMg6sVkwVROTddb1csCbOI83tufFvbMkwpbwImZ89joJ" }
    XCTAssertEqual(captureBase2Attributes.count, 3)

    let arrayCaptureBaseAttributes = attributes.filter { $0.captureBaseDigest == "ICFYTvQNUDNlVfS7_35nv1YpjDHx1EhlNqncFqd7zmyt" }
    XCTAssertEqual(arrayCaptureBaseAttributes.count, 2)
  }

  // MARK: Private

  private static let rootCaptureBaseDigest = "rootCaptureBaseDigest"
  private static let attributeMock = "attribute"
  private static let otherAttributeMock = "otherAttribute"
  private static let attributeTypeMock = AttributeType.text

  private let rootCaptureBaseMock = CaptureBase1x0(digest: rootCaptureBaseDigest, attributes: [attributeMock: attributeTypeMock, otherAttributeMock: .boolean], classification: nil, flaggedAttributes: nil)

  private var generator = OverlayBundleAttributesGenerator()

  private func createDataSourceOverlays(for dataSources: [String: JsonPath]) -> [DataSourceOverlay1x0] {
    dataSources.map { format, jsonPath in
      DataSourceOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, format: format, attributeSources: [Self.attributeMock: jsonPath])
    }
  }

  private func createLabelOverlays(for labels: [String: String]) -> [LabelOverlay1x0] {
    labels.map { language, label in
      LabelOverlay1x0(captureBaseDigest: Self.rootCaptureBaseDigest, language: language, attributeLabels: [Self.attributeMock: label], attributeCategories: nil, categoryLabels: nil)
    }
  }
}
