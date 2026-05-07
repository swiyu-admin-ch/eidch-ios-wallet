// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension StructuredJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    let nested = json[StructuredJWT.CodingKeys.test.rawValue] as! JSON
    XCTAssertEqual(nested.count, 2)
    XCTAssertEqual(nested[StructuredJWT.Nested.CodingKeys.testKey1.rawValue] as? String, test?.testKey1)
    XCTAssertEqual(nested[StructuredJWT.Nested.CodingKeys.testKey2.rawValue] as? String, test?.testKey2)
  }
}
