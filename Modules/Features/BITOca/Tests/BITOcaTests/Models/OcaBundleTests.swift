import Factory
import XCTest
@testable import BITOca
@testable import BITTestingCore

// swiftlint:disable force_unwrapping

// MARK: - OcaBundleTests

final class OcaBundleTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    setupSuccessState()
  }

  func testDecode_elfa() throws {
    let ocaBundle = OcaBundle.Mock.elfa

    XCTAssertEqual(ocaBundle.captureBases.count, 2)
    XCTAssertEqual(ocaBundle.captureBases[0].digest, "IBiT1Hjy50PCdVDp-EQLDePluS93MmJrWg5hKePPVzdq")
    XCTAssertEqual(ocaBundle.captureBases[1].digest, "ILFKGCCSyscqnYnMYl6QR-zD0UoNHuNqPpm9-5yiGMLz")
    XCTAssertEqual(ocaBundle.captureBases[0].attributes.count, 1)
    XCTAssertEqual(ocaBundle.captureBases[1].attributes.count, 17)

    let encodingOverlays = ocaBundle.overlays.compactMap { $0 as? CharacterEncodingOverlay1x0 }
    XCTAssertEqual(encodingOverlays.count, 1)

    let dataSourceOverlays = ocaBundle.overlays.compactMap { $0 as? DataSourceOverlay1x0 }
    XCTAssertEqual(dataSourceOverlays.count, 1)

    let formatOverlays = ocaBundle.overlays.compactMap { $0 as? FormatOverlay1x0 }
    XCTAssertEqual(formatOverlays.count, 1)

    let labelOverlays = ocaBundle.overlays.compactMap { $0 as? LabelOverlay1x0 }
    XCTAssertEqual(labelOverlays.count, 10)

    let metaOverlays = ocaBundle.overlays.compactMap { $0 as? MetaOverlay1x0 }
    XCTAssertEqual(metaOverlays.count, 5)

    let orderOverlay = ocaBundle.overlays.compactMap { $0 as? OrderOverlay1x0 }
    XCTAssertEqual(orderOverlay.count, 1)

    let standardOverlays = ocaBundle.overlays.compactMap { $0 as? StandardOverlay1x0 }
    XCTAssertEqual(standardOverlays.count, 1)
  }

  func testDecode_validatorFailure_throwsError() throws {
    ocaBundleValidatorSpy.validateThrowableError = TestingError.error

    XCTAssertThrowsError(try OcaBundler().createOcaBundle(OcaBundle.Mock.elfaData)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testDecode_standardOverlay() throws {
    let ocaBundle = OcaBundle.Mock.standardOverlay

    let standardOverlays = ocaBundle.overlays.compactMap { $0 as? StandardOverlay1x0 }
    XCTAssertEqual(standardOverlays.count, 1)

    let attributeStandards = standardOverlays.first!.attributeStandards
    XCTAssertEqual(attributeStandards.count, 2)
    let dataURLAttribute = attributeStandards.first { $0.key == "dataUrl" }!
    let unknownAttribute = attributeStandards.first { $0.key == "unknown" }!
    XCTAssertEqual(dataURLAttribute.value, .dataURLScheme)
    XCTAssertEqual(unknownAttribute.value, .unknown(rawString: "unknown"))
  }

  func testDecode_simpleSample() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    XCTAssertEqual(ocaBundle.captureBases.count, 1)
    XCTAssertEqual(ocaBundle.captureBases.first?.attributes.count, 3)
    XCTAssertEqual(ocaBundle.captureBases.first?.digest, "ICsJn_lrL5c1T7pDCEvvrHje0-3uZv9-IQ9Ky2inX-nV")
    XCTAssertEqual(ocaBundle.overlays.count, 9)
  }

  func testDecode_nested() throws {
    let ocaBundle = OcaBundle.Mock.nested

    XCTAssertEqual(ocaBundle.captureBases.count, 4)
    XCTAssertEqual(ocaBundle.captureBases[0].attributes.count, 3)
    XCTAssertEqual(ocaBundle.captureBases[0].digest, Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(ocaBundle.captureBases[1].attributes.count, 3)
    XCTAssertEqual(ocaBundle.captureBases[1].digest, Self.nestedCaptureBase1Digest)
    XCTAssertEqual(ocaBundle.captureBases[2].attributes.count, 3)
    XCTAssertEqual(ocaBundle.captureBases[2].digest, Self.nestedCaptureBase2Digest)
    XCTAssertEqual(ocaBundle.captureBases[3].attributes.count, 2)
    XCTAssertEqual(ocaBundle.captureBases[3].digest, Self.nestedArrayCaptureBaseDigest)
    XCTAssertEqual(ocaBundle.overlays.count, 20)
  }

  func testInit_argumentsPassed() throws {
    let bases = [CaptureBase1x0(digest: "digest", attributes: ["attribute": .text], classification: nil, flaggedAttributes: nil)]
    let overlays = try [DataSourceOverlay1x0(captureBaseDigest: "digest", format: "format", attributeSources: ["attribute": JsonPath(rawString: "$.jsonPath")])]
    _ = try OcaBundle(captureBases: bases, overlays: overlays)

    XCTAssertEqual(attributesGeneratorSpy.generateFromReceivedOcaBundle?.captureBases.count, 1)
    XCTAssertEqual(attributesGeneratorSpy.generateFromReceivedOcaBundle?.captureBases[0] as? CaptureBase1x0, bases[0])
    XCTAssertEqual(attributesGeneratorSpy.generateFromReceivedOcaBundle?.overlays.count, 1)
    XCTAssertEqual(attributesGeneratorSpy.generateFromReceivedOcaBundle?.overlays[0] as? DataSourceOverlay1x0, overlays[0])
  }

  func testGetAttributes_noDigestGiven_returnsAll() throws {
    attributesGeneratorSpy.generateFromReturnValue = [attribute1Mock, attribute2Mock, otherAttributeMock]
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attributes = ocaBundle.getAttributes()

    XCTAssertEqual(attributes.count, 3)
  }

  func testGetAttributes_digestGiven_returnsOnlyAttributesForBase() throws {
    attributesGeneratorSpy.generateFromReturnValue = [attribute1Mock, attribute2Mock, otherAttributeMock]
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attributes = ocaBundle.getAttributes(digest: Self.rootCaptureBaseDigest)

    XCTAssertEqual(attributes.count, 2)
  }

  func testGetAttributes_invalidDigest_returnsEmptyList() throws {
    attributesGeneratorSpy.generateFromReturnValue = [attribute1Mock, attribute2Mock, otherAttributeMock]
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attributes = ocaBundle.getAttributes(digest: "otherDigest")

    XCTAssertEqual(attributes.count, 0)
  }

  func testGetAttributeForJsonPath_equalJsonPath_returnsAttribute() throws {
    let jsonPath = try JsonPath(rawString: "$.jsonPath")
    let attributeMock = createJsonPathAttribute(jsonPath: jsonPath)
    attributesGeneratorSpy.generateFromReturnValue = [attributeMock]
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: jsonPath)

    XCTAssertEqual(attribute?.name, Self.jsonPathAttributeName)
  }

  func testGetAttributeForJsonPath_unequalJsonPath_returnsNil() throws {
    let attributeMock = try createJsonPathAttribute(jsonPath: JsonPath(rawString: "$.jsonPath"))
    attributesGeneratorSpy.generateFromReturnValue = [attributeMock]
    let ocaBundle = try OcaBundle(captureBases: [rootCaptureBaseMock], overlays: [])

    let attribute = try ocaBundle.getAttributeForJsonPath(jsonPath: JsonPath(rawString: "$.otherJsonPath"))

    XCTAssertNil(attribute)
  }

  func testGetLatestOverlaysOfType_oneOverlayType_returnsOverlay() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    let labelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label)
    XCTAssertEqual(labelOverlays.count, 2)

    let dataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource)
    XCTAssertEqual(dataSourceOverlays.count, 1)

    let brandingOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .branding)
    XCTAssertEqual(brandingOverlays.count, 2)
  }

  func testGetLatestOverlaysOfType_oneOverlayTypeWithDigest_returnsOverlayForDigest() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let rootLabelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label, digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(rootLabelOverlays.count, 2)
    let rootDataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource, digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(rootDataSourceOverlays.count, 1)

    let brandingOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .branding, digest: Self.nestedCaptureBase1Digest)
    XCTAssertEqual(brandingOverlays.count, 0)
    let dataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource, digest: Self.nestedCaptureBase1Digest)
    XCTAssertEqual(dataSourceOverlays.count, 1)
    let labelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label, digest: Self.nestedCaptureBase1Digest)
    XCTAssertEqual(labelOverlays.count, 1)
    let metaOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .meta, digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(metaOverlays.count, 2)
    let orderOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .order, digest: Self.nestedCaptureBase1Digest)
    XCTAssertEqual(orderOverlays.count, 1)
  }

  func testRootCaptureBase_resolvesRoot() throws {
    rootCaptureBaseResolverSpy.resolveReturnValue = rootCaptureBaseMock

    let ocaBundle = OcaBundle.Mock.elfa

    XCTAssertEqual(ocaBundle.rootCaptureBaseDigest, rootCaptureBaseMock.digest)
  }

  // MARK: Private

  private static let nestedRootCaptureBaseDigest = "IK4ceQ-qvbporNvdFExEAMQrPud9OutHQbB2pc2iXrvW"
  private static let nestedCaptureBase1Digest = "IACad8m8doJZoyOwmkcSOGD0OKL6JoNtC22I1K4DlFMh"
  private static let nestedCaptureBase2Digest = "IMg6sVkwVROTddb1csCbOI83tufFvbMkwpbwImZ89joJ"
  private static let nestedArrayCaptureBaseDigest = "ICFYTvQNUDNlVfS7_35nv1YpjDHx1EhlNqncFqd7zmyt"

  private static let rootCaptureBaseDigest = "rootCaptureBase"
  private static let otherCaptureBaseDigest = "otherCaptureBase"
  private static let jsonPathAttributeName = "jsonPathAttributeName"
  private static let formatMock = "vc+sd-jwt"

  private let attribute1Mock = OverlayBundleAttribute(captureBaseDigest: rootCaptureBaseDigest, name: "attribute1", attributeType: .text)
  private let attribute2Mock = OverlayBundleAttribute(captureBaseDigest: rootCaptureBaseDigest, name: "attribute2", attributeType: .text)
  private let otherAttributeMock = OverlayBundleAttribute(captureBaseDigest: otherCaptureBaseDigest, name: "otherAttribute", attributeType: .text)
  private let rootCaptureBaseMock = CaptureBase1x0(digest: rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)

  private var attributesGeneratorSpy = OverlayBundleAttributesGeneratorProtocolSpy()
  private var ocaBundleValidatorSpy = OcaBundleValidatorProtocolSpy()
  private var rootCaptureBaseResolverSpy = RootCaptureBaseResolverProtocolSpy()

  private func registerMocks() {
    attributesGeneratorSpy = OverlayBundleAttributesGeneratorProtocolSpy()
    Container.shared.overlayBundleAttributesGenerator.register { self.attributesGeneratorSpy }
    Container.shared.ocaBundleValidator.register { self.ocaBundleValidatorSpy }
    Container.shared.rootCaptureBaseResolver.register { self.rootCaptureBaseResolverSpy }
  }

  private func setupSuccessState() {
    attributesGeneratorSpy.generateFromReturnValue = [attribute1Mock, attribute2Mock]
    rootCaptureBaseResolverSpy.resolveReturnValue = rootCaptureBaseMock
  }

  private func createJsonPathAttribute(jsonPath: JsonPath) -> OverlayBundleAttribute {
    OverlayBundleAttribute(captureBaseDigest: Self.rootCaptureBaseDigest, name: Self.jsonPathAttributeName, attributeType: .text, dataSources: [Self.formatMock: jsonPath])
  }
}
