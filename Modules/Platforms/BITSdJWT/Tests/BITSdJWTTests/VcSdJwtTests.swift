import Foundation
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITSdJWT
@testable import BITSdJWTMocks

final class VcSdJwtTests: XCTestCase {

  // MARK: Internal

  func testDecode_allFields() throws {
    let data = VcSdJwtPayload.Mock.allFieldsData

    let sdJwt = try decoder.decode(VcSdJwtPayload.self, from: data)
    let payload = sdJwt.payload

    let expectedJwk = PublicKeyInfo.JWK(kty: "key_type", kid: nil, crv: "curve", x: "test_x", y: "test_y")
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 111, uri: "status_list_uri"))

    XCTAssertEqual(sdJwt.header.type, "vc+sd-jwt")
    XCTAssertEqual(payload.issuer, "issuer")
    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(payload.keyBinding, expectedJwk)
    XCTAssertEqual(payload.vct, "vc_type")
    XCTAssertEqual(payload.vctIntegrity, "vct_integrity")
    XCTAssertEqual(payload.statusList, expectedStatusList)
    XCTAssertEqual(payload.subject, "subject")
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }

  func testDecode_requiredFields() throws {
    let data = VcSdJwtPayload.Mock.requiredFieldsData

    let sdJwt = try decoder.decode(VcSdJwtPayload.self, from: data)
    let payload = sdJwt.payload

    XCTAssertEqual(payload.issuer, "issuer")
    XCTAssertEqual(payload.vct, "vc_type")
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()

}
