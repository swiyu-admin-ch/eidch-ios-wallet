import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITSdJWT
@testable import BITSdJWTMocks

final class VcSdJwtTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testDecode_allFields_success() throws {
    let vcSdJWS = VcSdJWS.Mock.sample
    try assertVcSdJwt(vcSdJWS)
  }

  func testDecode_withoutKeyBinding_success() throws {
    let vcSdJWS = VcSdJWS.Mock.noKeyBinding
    try assertVcSdJwt(vcSdJWS)
  }

  func testDecode_withOneReservedClaim_success() throws {
    let vcSdJWS = VcSdJWS.Mock.reservedClaimsWithOneClaim
    try assertVcSdJwt(vcSdJWS, vctMetadataUri: Self.vctUrlMock, vctMetadataUriIntegrity: Self.vctIntegrityMock)
  }

  func testDecode_vctMetadataUri_success() throws {
    let vcSdJwt = VcSdJWS.Mock.vctMetadataUri
    try assertVcSdJwt(
      vcSdJwt,
      vct: "identity_credential",
      vctIntegrity: nil,
      vctMetadataUri: Self.vctUrlMock,
      vctMetadataUriIntegrity: Self.vctIntegrityMock)
  }

  // MARK: Private

  private static let vctUrlMock = "https://credentials.example.com/identity_credential"
  private static let vctIntegrityMock = "sha265-onXnKxyPhvWaqkNqWgpL0r1lEoBfLIsJQfFuY5ydHPg"

  private func assertVcSdJwt(_ jws: VcSdJWS, vct: String = vctUrlMock, vctIntegrity: String? = vctIntegrityMock, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) throws {
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 285, uri: "https://example.com/statuslist/example.jwt"))
    let jwt = jws.payload
    XCTAssertEqual(jws.header.type, "vc+sd-jwt")
    XCTAssertEqual(jwt.issuer, "did:tdw:example")
    XCTAssertEqual(jwt.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(jwt.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(jwt.vct, vct)
    XCTAssertEqual(jwt.vctIntegrity, vctIntegrity)
    XCTAssertEqual(jwt.vctMetadataUri, vctMetadataUri)
    XCTAssertEqual(jwt.vctMetadataUriIntegrity, vctMetadataUriIntegrity)
    XCTAssertEqual(jwt.statusList, expectedStatusList)
    XCTAssertEqual(jwt.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }

}
