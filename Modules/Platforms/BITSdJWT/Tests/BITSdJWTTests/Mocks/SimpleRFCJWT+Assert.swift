// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension SimpleRFCJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 10)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.issuer.rawValue] as? String, issuer)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.issuedAt.rawValue] as? Double, issuedAt?.timeIntervalSince1970)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.expiredAt.rawValue] as? Double, expiredAt?.timeIntervalSince1970)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.subject.rawValue] as? String, subject)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.givenName.rawValue] as? String, givenName)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.familyName.rawValue] as? String, familyName)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.email.rawValue] as? String, email)
    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.phoneNumber.rawValue] as? String, phoneNumber)

    let addressJson = json[SimpleRFCJWT.CodingKeys.address.rawValue] as! JSON
    XCTAssertEqual(addressJson.count, 4)
    XCTAssertEqual(addressJson[SimpleRFCJWT.Address.CodingKeys.street.rawValue] as? String, address?.street)
    XCTAssertEqual(addressJson[SimpleRFCJWT.Address.CodingKeys.locality.rawValue] as? String, address?.locality)
    XCTAssertEqual(addressJson[SimpleRFCJWT.Address.CodingKeys.region.rawValue] as? String, address?.region)
    XCTAssertEqual(addressJson[SimpleRFCJWT.Address.CodingKeys.country.rawValue] as? String, address?.country)

    XCTAssertEqual(json[SimpleRFCJWT.CodingKeys.birthdate.rawValue] as? String, birthdate)
  }
}
