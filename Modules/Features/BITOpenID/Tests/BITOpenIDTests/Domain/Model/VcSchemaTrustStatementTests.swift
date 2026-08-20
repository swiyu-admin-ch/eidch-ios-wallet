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
    let rawSdJwt = VcSchemaTrustStatementJWT.Mock.issuanceRawSdJwtData

    let trustStatement = try decoder.decode(VcSchemaTrustStatementJWT.self, from: rawSdJwt)

    assertTrustStatement(trustStatement.resolvedPayload, vct: "TrustStatementIssuanceV1")
  }

  func testDecode_verification() throws {
    let rawSdJwt = VcSchemaTrustStatementJWT.Mock.verificationRawSdJwtData

    let trustStatement = try decoder.decode(VcSchemaTrustStatementJWT.self, from: rawSdJwt)

    assertTrustStatement(trustStatement.resolvedPayload, vct: "TrustStatementVerificationV1")
  }

  // MARK: Private

  private var decoder = VcSdJWSDecoder()

  private func assertTrustStatement(_ trustStatement: VcSchemaTrustStatementJWT, vct: String) {
    let expectedStatus = VcSdJwtTokenStatus(statusList: VcSdJwtTokenStatus.StatusList(index: 30, uri: "status_list_uri"))
    XCTAssertEqual(trustStatement.vct, vct)
    XCTAssertEqual(trustStatement.subject, "subject")
    XCTAssertEqual(trustStatement.issuedAt, Date(timeIntervalSince1970: 1742453211))
    XCTAssertEqual(trustStatement.statusList, expectedStatus)

    XCTAssertEqual(trustStatement.activatedAt, Date(timeIntervalSince1970: 1742453210))
    XCTAssertEqual(trustStatement.expiredAt, Date(timeIntervalSince1970: 2209014000))

    XCTAssertEqual(trustStatement.vcSchemaId?.absoluteString, "vcSchemaId")
  }
}
