// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Foundation
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITSdJWT
@testable import BITSdJWTMocks

final class VcSdJwtTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    decoder = SdJWSDecoder()
  }

  func testDecode_allFields() throws {
    let vcSdJwt = VcSdJwtPayload.Mock.allFieldsData
    try assertVcSdJwt(vcSdJwt)
  }

  // MARK: - Hotfix decoding

  func testDecode_expandedFormat_success() throws {
    let vcSdJwt = VcSdJwtPayload.ExpandedMock.validSample
    try assertVcSdJwt(vcSdJwt)
  }

  func testDecode_expandedFormatWithoutJWK_success() throws {
    let vcSdJwt = VcSdJwtPayload.ExpandedMock.sampleWithoutJwk
    try assertVcSdJwt(vcSdJwt)
  }

  func testDecode_expandedFormatWithoutKeyDetails_success() throws {
    let vcSdJwt = VcSdJwtPayload.ExpandedMock.sampleWithoutKeyDetails
    try assertVcSdJwt(vcSdJwt)
  }

  // MARK: Private

  private var decoder: SdJWSDecoder!

  private func assertVcSdJwt(_ data: Data) throws {
    let vcSdJwt = try decoder.decode(VcSdJwtPayload.self, from: data)
    let payload = vcSdJwt.payload
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 285, uri: "https://example.com/statuslist/example.jwt"))

    XCTAssertEqual(vcSdJwt.header.type, "vc+sd-jwt")
    XCTAssertEqual(payload.issuer, "did:tdw:example")
    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(payload.vct, "https://credentials.example.com/identity_credential")
    XCTAssertEqual(payload.vctIntegrity, "sha265-onXnKxyPhvWaqkNqWgpL0r1lEoBfLIsJQfFuY5ydHPg")
    XCTAssertEqual(payload.statusList, expectedStatusList)
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }

}
