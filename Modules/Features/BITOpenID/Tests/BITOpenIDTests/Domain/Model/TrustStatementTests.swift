// swiftlint:disable force_unwrapping
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class TrustStatementTests: XCTestCase {

  // MARK: Internal

  func testDecode_allFields() throws {
    let trustStatement = TrustStatementPayload.Mock.allFields

    let payload = trustStatement.payload

    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 111, uri: "status_list_uri"))

    XCTAssertEqual(payload.vct, "TrustStatementIdentityV1")
    XCTAssertEqual(payload.issuer, "issuer")
    XCTAssertEqual(payload.subject, "subject")
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1742453211))
    XCTAssertEqual(payload.statusList, expectedStatusList)

    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1742453210))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 2209014000))

    XCTAssertEqual(payload.entityNames.count, 2)
    let deCHEntityName = payload.entityNames.first { $0.key == "de-CH" }!
    XCTAssertEqual(deCHEntityName.value, "de-CH entityName")
    let enEntityName = payload.entityNames.first { $0.key == "en" }!
    XCTAssertEqual(enEntityName.value, "EN entityName")

    XCTAssertEqual(payload.registryIds.count, 2)
    let registryId1 = payload.registryIds.first { $0.type == "registryId1" }!
    XCTAssertEqual(registryId1.value, "registryId1Value")
    let registryId2 = payload.registryIds.first { $0.type == "registryId1" }!
    XCTAssertEqual(registryId2.value, "registryId1Value")

    XCTAssertEqual(payload.isStateActor, true)
  }

  func testGetLocalizedEntityName_multipleLanguages_returnsFirstValidLanguage() throws {
    let trustStatement = TrustStatementPayload.Mock.validSample

    let clientName = trustStatement.getLocalizedEntityName(considering: ["cz", "de", "en"])

    XCTAssertEqual(clientName, "de-CH entityName")
  }

  func testGetLocalizedEntityName_noLanguages_returnsFirstValidLanguage() throws {
    let trustStatement = TrustStatementPayload.Mock.validSample

    let clientName = trustStatement.getLocalizedEntityName(considering: [])

    XCTAssertEqual(clientName, "entityName")
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()
}

// swiftlint:enable all
