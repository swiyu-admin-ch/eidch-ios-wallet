// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension DuplicateNameJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 3)
    XCTAssertEqual(json[DuplicateNameJWT.CodingKeys.testKey1.rawValue] as? String, testKey1)

    let nested1 = json[DuplicateNameJWT.CodingKeys.testKey2.rawValue] as! JSON
    XCTAssertEqual(nested1.count, 1)
    XCTAssertEqual(nested1[DuplicateNameJWT.Nested1.CodingKeys.key.rawValue] as? String, testKey2?.key)

    let nested2 = json[DuplicateNameJWT.CodingKeys.testKey3.rawValue] as! JSON
    XCTAssertEqual(nested2.count, 1)
    XCTAssertEqual(nested2[DuplicateNameJWT.Nested2.CodingKeys.key.rawValue] as? String, testKey3.key)
  }
}
