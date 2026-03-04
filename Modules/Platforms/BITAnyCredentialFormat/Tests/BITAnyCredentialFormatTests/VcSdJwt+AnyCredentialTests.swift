import XCTest
@testable import BITAnyCredentialFormat
@testable import BITSdJWT
@testable import BITSdJWTMocks

final class VcSdJwtAnyCredentialTests: XCTestCase {

  // MARK: Internal

  func testGetClaimsDictionary_all_returnsAll() {
    let jws = VcSdJWS.Mock.reservedClaimsWithOneClaim

    let claims = jws.getClaimsDictionary(.all)

    XCTAssertEqual(claims.count, 16)
    XCTAssertEqual(claims[claimKeyMock] as? String, claimValueMock)
    XCTAssertTrue(SdJWSDecoder.reservedClaimNames.allSatisfy { claims.keys.contains($0) })
  }

  func testGetClaimsDictionary_nonTechnical_returnsClaimsWithoutReservedNames() {
    let jws = VcSdJWS.Mock.reservedClaimsWithOneClaim

    let claims = jws.getClaimsDictionary(.nonTechnical)

    XCTAssertEqual(claims.count, 1)
    XCTAssertEqual(claims[claimKeyMock] as? String, claimValueMock)
  }

  // MARK: Private

  private let claimKeyMock = "testKey"
  private let claimValueMock = "testValue"

}
