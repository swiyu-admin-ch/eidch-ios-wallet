import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class TrustStatementTests: XCTestCase {

  // MARK: Internal

  func testDecode_allFields() throws {
    let data = TrustStatementPayload.Mock.allFieldsData

    let sdJwt = try decoder.decode(TrustStatementPayload.self, from: data)
    let payload = sdJwt.payload

    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 111, uri: "status_list_uri"))

    XCTAssertEqual(sdJwt.header.type, "vc+sd-jwt")
    XCTAssertEqual(payload.issuer, "issuer")
    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(payload.vct, "vc_type")
    XCTAssertEqual(payload.statusList, expectedStatusList)
    XCTAssertEqual(payload.subject, "subject")
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()
}
