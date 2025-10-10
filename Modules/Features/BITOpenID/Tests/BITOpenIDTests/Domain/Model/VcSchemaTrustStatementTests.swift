// swiftlint:disable force_unwrapping
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class VcSchemaTrustStatementTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testDecode_issuance() throws {
    let rawSdJwt = VcSchemaTrustStatementPayload.Mock.issuanceRawSdJwtData

    let trustStatement = try decoder.decode(VcSchemaTrustStatementPayload.self, from: rawSdJwt)

    assertTrustStatement(trustStatement.payload, vct: "TrustStatementIssuanceV1")
  }

  func testDecode_verification() throws {
    let rawSdJwt = VcSchemaTrustStatementPayload.Mock.verificationRawSdJwtData

    let trustStatement = try decoder.decode(VcSchemaTrustStatementPayload.self, from: rawSdJwt)

    assertTrustStatement(trustStatement.payload, vct: "TrustStatementVerificationV1")
  }

  // MARK: Private

  private var decoder = SdJWSDecoder()

  private func assertTrustStatement(_ trustStatement: VcSchemaTrustStatementPayload, vct: String) {
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 30, uri: "status_list_uri"))
    XCTAssertEqual(trustStatement.vct, vct)
    XCTAssertEqual(trustStatement.issuer, "issuer")
    XCTAssertEqual(trustStatement.subject, "subject")
    XCTAssertEqual(trustStatement.issuedAt, Date(timeIntervalSince1970: 1742453211))
    XCTAssertEqual(trustStatement.statusList, expectedStatusList)

    XCTAssertEqual(trustStatement.activatedAt, Date(timeIntervalSince1970: 1742453210))
    XCTAssertEqual(trustStatement.expiredAt, Date(timeIntervalSince1970: 2209014000))

    XCTAssertEqual(trustStatement.vcSchemaId?.absoluteString, "vcSchemaId")
  }
}
