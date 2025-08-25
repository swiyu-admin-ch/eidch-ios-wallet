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
    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1742453210))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 2209014000))
    XCTAssertEqual(payload.vct, "vc_type")
    XCTAssertEqual(payload.statusList, expectedStatusList)
    XCTAssertEqual(payload.subject, "subject")
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1742453211))
  }

  func testDecode_localizedIssuer() throws {
    let trustStatement = TrustStatementPayload.Mock.validSample

    XCTAssertNotNil(trustStatement.localizedIssuer["en"])
    XCTAssertNotNil(trustStatement.localizedIssuer["de-CH"])
    XCTAssertEqual(trustStatement.localizedIssuer.keys.count, 2)
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()
}
