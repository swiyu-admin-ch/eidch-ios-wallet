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
    let vcSdJwt = VcSdJwtPayload.Mock.sample
    try assertVcSdJwt(vcSdJwt)
  }

  func testDecode_withoutKeyBinding_success() throws {
    let vcSdJwt = VcSdJwtPayload.Mock.noKeyBinding
    try assertVcSdJwt(vcSdJwt)
  }

  func testDecode_withOneReservedClaim_success() throws {
    let vcSdJwt = VcSdJwtPayload.Mock.reservedClaimsWithOneClaim
    try assertVcSdJwt(vcSdJwt, vctMetadataUri: Self.vctUrlMock, vctMetadataUriIntegrity: Self.vctIntegrityMock)
  }

  func testDecode_vctMetadataUri_success() throws {
    let vcSdJwt = VcSdJwtPayload.Mock.vctMetadataUri
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

  private func assertVcSdJwt(_ vcSdJwt: VcSdJwt, vct: String = vctUrlMock, vctIntegrity: String? = vctIntegrityMock, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) throws {
    let payload = vcSdJwt.payload
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 285, uri: "https://example.com/statuslist/example.jwt"))

    XCTAssertEqual(vcSdJwt.header.type, "vc+sd-jwt")
    XCTAssertEqual(payload.issuer, "did:tdw:example")
    XCTAssertEqual(payload.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(payload.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(payload.vct, vct)
    XCTAssertEqual(payload.vctIntegrity, vctIntegrity)
    XCTAssertEqual(payload.vctMetadataUri, vctMetadataUri)
    XCTAssertEqual(payload.vctMetadataUriIntegrity, vctMetadataUriIntegrity)
    XCTAssertEqual(payload.statusList, expectedStatusList)
    XCTAssertEqual(payload.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }

}
