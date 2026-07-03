import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension FlatJWT {

  func assertIn(_ json: JSON) {
    let assignedValues = [testKey1, testKey2, testKey3].compactMap { $0 }
    XCTAssertEqual(json.count, assignedValues.count)
    XCTAssertEqual(json[FlatJWT.CodingKeys.testKey1.rawValue] as? String, testKey1)
    XCTAssertEqual(json[FlatJWT.CodingKeys.testKey2.rawValue] as? String, testKey2)
    XCTAssertEqual(json[FlatJWT.CodingKeys.testKey3.rawValue] as? String, testKey3)
  }
}

extension SdJWS<FlatJWT> {
  func assertDisclosures() {
    XCTAssertEqual(disclosures.count, 3)
    disclosures.assertContains([.string(FlatJWT.CodingKeys.testKey1.rawValue)], rawDisclosure: FlatJWT.Mock.disclosure1)
    disclosures.assertContains([.string(FlatJWT.CodingKeys.testKey2.rawValue)], rawDisclosure: FlatJWT.Mock.disclosure2)
    disclosures.assertContains([.string(FlatJWT.CodingKeys.testKey3.rawValue)], rawDisclosure: FlatJWT.Mock.disclosure3)
  }
}
