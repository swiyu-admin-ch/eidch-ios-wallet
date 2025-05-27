import XCTest
@testable import BITOca

// swiftlint:disable force_unwrapping

// MARK: - OcaBundleTests

final class OcaBundleTests: XCTestCase {

  // MARK: Internal

  func testDecode_elfa() throws {
    let ocaBundle = OcaBundle.Mock.elfa

    XCTAssertEqual(ocaBundle.captureBases.count, 1)
    XCTAssertEqual(ocaBundle.captureBases.first?.attributes.count, 17)

    let labelOverlays = ocaBundle.overlays.compactMap { $0 as? LabelOverlay1x0 }
    XCTAssertEqual(labelOverlays.count, 2)

    let dataSourceOverlays = ocaBundle.overlays.compactMap { $0 as? DataSourceOverlay1x0 }
    XCTAssertEqual(dataSourceOverlays.count, 1)
  }

  func testDecode_simpleSample() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    XCTAssertEqual(ocaBundle.captureBases.count, 1)
    XCTAssertEqual(ocaBundle.captureBases.first?.attributes.count, 2)
    XCTAssertEqual(ocaBundle.overlays.count, 3)
  }

  func testDecode_nested() throws {
    let ocaBundle = OcaBundle.Mock.nested

    XCTAssertEqual(ocaBundle.captureBases.count, 2)
    XCTAssertEqual(ocaBundle.captureBases[0].attributes.count, 6)
    XCTAssertEqual(ocaBundle.captureBases[1].attributes.count, 2)
    XCTAssertEqual(ocaBundle.overlays.count, 4)
  }

  func testGetAttributes_simpleSample_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    let attributes = ocaBundle.getAttributes()

    XCTAssertEqual(attributes.count, 2)
    let lastName = attributes.first { $0.name == "lastName" }!
    assertAttribute(lastName, name: "lastName", type: .text)
    let isOver18 = attributes.first { $0.name == "isOver18" }!
    assertAttribute(isOver18, name: "isOver18", type: .boolean)
  }

  func testGetAttributes_nested_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attributes = ocaBundle.getAttributes()

    XCTAssertEqual(attributes.count, 8)
  }

  func testGetAttributes_nestedWithDigest_returnsAttributesForDigest() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let rootBaseAttributes = ocaBundle.getAttributes(digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(rootBaseAttributes.count, 6)

    let attributes = ocaBundle.getAttributes(digest: Self.nestedOtherCaptureBaseDigest)
    XCTAssertEqual(attributes.count, 2)
  }

  func testGetAttributes_invalidDigest_returnsEmptyList() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    let attributes = ocaBundle.getAttributes(digest: "otherDigest")

    XCTAssertEqual(attributes.count, 0)
  }

  func testGetAttributeForJsonPath_oneLevelPath_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: "$.lastName")

    XCTAssertEqual(attribute?.name, "lastName")
  }

  func testGetAttributeForJsonPath_twoLevelPath_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: "$.address.street")

    XCTAssertEqual(attribute?.name, "address_street")
  }

  func testGetAttributeForJsonPath_arrayIndexPath_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: "$.pets[0].name")

    XCTAssertEqual(attribute?.name, "name")
  }

  func testGetAttributeForJsonPath_arrayWildcardPath_returnsAttributes() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: "$.pets[*].name")

    XCTAssertEqual(attribute?.name, "name")
  }

  func testGetAttributeForJsonPath_invalidPath_returnsNil() throws {
    let ocaBundle = OcaBundle.Mock.nested

    XCTAssertNil(ocaBundle.getAttributeForJsonPath(jsonPath: "$"))
    XCTAssertNil(ocaBundle.getAttributeForJsonPath(jsonPath: "$."))
    XCTAssertNil(ocaBundle.getAttributeForJsonPath(jsonPath: "invalid"))
    XCTAssertNil(ocaBundle.getAttributeForJsonPath(jsonPath: "$.invalid"))
  }

  func testGetAttributeForJsonPath_emptyPath_returnsNil() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let attribute = ocaBundle.getAttributeForJsonPath(jsonPath: "")

    XCTAssertNil(attribute)
  }

  func testGetLatestOverlaysOfType_oneOverlayType_returnsOverlay() throws {
    let ocaBundle = OcaBundle.Mock.simpleSample

    let labelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label)
    XCTAssertEqual(labelOverlays.count, 2)

    let dataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource)
    XCTAssertEqual(dataSourceOverlays.count, 1)
  }

  func testGetLatestOverlaysOfType_oneOverlayTypeWithDigest_returnsOverlayForDigest() throws {
    let ocaBundle = OcaBundle.Mock.nested

    let rootLabelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label, digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(rootLabelOverlays.count, 1)
    let rootDataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource, digest: Self.nestedRootCaptureBaseDigest)
    XCTAssertEqual(rootDataSourceOverlays.count, 1)

    let labelOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label, digest: Self.nestedOtherCaptureBaseDigest)
    XCTAssertEqual(labelOverlays.count, 1)
    let dataSourceOverlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource, digest: Self.nestedOtherCaptureBaseDigest)
    XCTAssertEqual(dataSourceOverlays.count, 1)
  }

  // MARK: Private

  private static let simpleCaptureBaseDigest = "IFGp2Z7bUcN2ZBywYXO5poVj3koUUdHGrN0Fn0yKGaJG"
  private static let nestedRootCaptureBaseDigest = "IDif6Jd863C_YYjp1cHFCTAUr1_TzZSS1l-pv21Q56qs"
  private static let nestedOtherCaptureBaseDigest = "IKLvtGx1NU0007DUTTmI_6Zw-hnGRFicZ5R4vAxg4j2j"
  private static let formatMock = "vc+sd-jwt"

  private func assertAttribute(_ attribute: OverlayBundleAttribute, name: String, type: AttributeType) {
    XCTAssertEqual(attribute.attributeType, type)
    XCTAssertEqual(attribute.captureBaseDigest, Self.simpleCaptureBaseDigest)

    let expectedLabels = ["de-CH": "\(name) de-CH", "en-US": "\(name) en-US"]
    XCTAssertEqual(attribute.labels, expectedLabels)

    let expectedDataSources = [Self.formatMock: "$.\(name)"]
    XCTAssertEqual(attribute.dataSources, expectedDataSources)
  }
}
