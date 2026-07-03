import XCTest
@testable import BITAnyCredentialFormat
@testable import BITSdJWT

final class VcSdJwtAnyCredentialTests: XCTestCase {

  // MARK: Internal

  func testBusinessExpiryDate_pastDate_returnsValidDate() throws {
    let jws = makeJws(expiryDate: "2020-01-01")

    let businessExpiryDate = try XCTUnwrap(jws.businessExpiryDate)

    XCTAssertEqual(businessExpiryDate, expectedBusinessExpiryDate(from: "2020-01-01"))
  }

  func testBusinessExpiryDate_futureDate_returnsValidDate() throws {
    let jws = makeJws(expiryDate: "2099-12-31")

    let businessExpiryDate = try XCTUnwrap(jws.businessExpiryDate)

    XCTAssertEqual(businessExpiryDate, expectedBusinessExpiryDate(from: "2099-12-31"))
  }

  func testBusinessExpiryDate_withoutExpiryDateDisclosure_returnsNil() {
    let jws = VcSdJWS.Mock.sample

    XCTAssertNil(jws.businessExpiryDate)
  }

  func testBusinessExpiryDate_invalidFormat_returnsNil() {
    let jws = makeJws(expiryDate: "01-01-2020")

    XCTAssertNil(jws.businessExpiryDate)
  }

  func testBusinessExpiryDate_invalidValue_returnsNil() {
    let jws = makeJws(expiryDate: "not-a-date")

    XCTAssertNil(jws.businessExpiryDate)
  }

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

  private func makeJws(expiryDate: String) -> VcSdJWS {
    let base = VcSdJWS.Mock.sample
    var resolvedJSON = base.resolvedJSON
    resolvedJSON["expiry_date"] = expiryDate
    return VcSdJWS(
      jws: base,
      payload: base.resolvedPayload,
      resolvedJSON: resolvedJSON,
      rawSdJWS: base.rawSdJWS,
      digestAlgorithm: base.digestAlgorithm,
      disclosures: base.disclosures,
      rawKeyBinding: base.rawKeyBinding,
      keyIdentifierDid: base.keyIdentifierDid)
  }

  private func expectedBusinessExpiryDate(from dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    guard let date = formatter.date(from: dateString) else { return nil }
    return Calendar.current.date(byAdding: .day, value: 1, to: date)
  }

}
