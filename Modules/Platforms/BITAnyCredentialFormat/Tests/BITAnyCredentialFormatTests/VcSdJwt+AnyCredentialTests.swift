import XCTest
@testable import BITAnyCredentialFormat
@testable import BITSdJWT

final class VcSdJwtAnyCredentialTests: XCTestCase {

  // MARK: Internal

  func testGetClaimsJSON_all_returnsAll() {
    let jws = VcSdJWS.Mock.sample

    let claims = jws.getClaimsJSON(.all)

    XCTAssertEqual(claims.count, 12)
    XCTAssertEqual(claims[claimKey1Mock] as? String, claimValue1Mock)
    XCTAssertEqual(claims[claimKey2Mock] as? String, claimValue2Mock)
    for claim in VcSdJWSDecoder.nonSelectivelyDisclosableClaims {
      if claim != "_sd" && claim != "_sd_alg" { // get removed during decoding
        XCTAssertNotNil(claims[claim], "Claim: \(claim)")
      }
    }
  }

  func testGetClaimsJSON_nonTechnical_returnsClaimsWithoutTechnical() {
    let jws = VcSdJWS.Mock.sample

    let claims = jws.getClaimsJSON(.nonTechnical)

    XCTAssertEqual(claims.count, 2)
    XCTAssertEqual(claims[claimKey1Mock] as? String, claimValue1Mock)
    XCTAssertEqual(claims[claimKey2Mock] as? String, claimValue2Mock)
  }

  // MARK: Private

  private let claimKey1Mock = "test_key_1"
  private let claimValue1Mock = "test_value_1"
  private let claimKey2Mock = "test_key_2"
  private let claimValue2Mock = "test_value_2"

}
