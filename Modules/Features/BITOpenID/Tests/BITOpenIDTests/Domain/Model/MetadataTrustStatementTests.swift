// swiftlint:disable force_unwrapping
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class MetadataTrustStatementTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testDecode_allFields() throws {
    let trustStatement = MetadataTrustStatementPayload.Mock.allFields

    let payload = trustStatement.payload

    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 111, uri: "status_list_uri"))

    XCTAssertEqual(payload.vct, "TrustStatementMetadataV1")
    XCTAssertEqual(payload.issuer, "issuer")
    XCTAssertEqual(payload.subject, "subject")
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1742453211))
    XCTAssertEqual(payload.statusList, expectedStatusList)

    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1742453210))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 2209014000))

    XCTAssertEqual(payload.entityNames.count, 2)
    let deCHEntityName = payload.entityNames.first { $0.key == "de-CH" }!
    XCTAssertEqual(deCHEntityName.value, "de-CH orgName")
    let enEntityName = payload.entityNames.first { $0.key == "en" }!
    XCTAssertEqual(enEntityName.value, "EN orgName")

    XCTAssertEqual(payload.preferredLanguage, "de-CH")
  }

  func testGetLocalizedEntityName_multipleLanguages_returnsFirstValidLanguage() throws {
    let trustStatement = MetadataTrustStatementPayload.Mock.allFields

    let clientName = trustStatement.resolvedPayload.getLocalizedEntityName(considering: ["cz", "de", "en"])

    XCTAssertEqual(clientName, "de-CH orgName")
  }

  func testGetLocalizedEntityName_noLanguagesButPreferredLanguage_returnsPreferredLanguage() throws {
    let trustStatement = MetadataTrustStatementPayload.Mock.allFields

    let clientName = trustStatement.resolvedPayload.getLocalizedEntityName(considering: [])

    XCTAssertEqual(clientName, "de-CH orgName")
  }

  func testGetLocalizedEntityName_noLanguages_returnsKey() throws {
    let trustStatement = MetadataTrustStatementPayload.Mock.validSample

    let clientName = trustStatement.resolvedPayload.getLocalizedEntityName(considering: [])

    XCTAssertEqual(clientName, "orgName")
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()
}
