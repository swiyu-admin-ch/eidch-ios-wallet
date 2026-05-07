import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension FlatSimpleArrayJWT {

  func assertIn(_ json: JSON) {
    if let testValue1 {
      XCTAssertEqual(json.count, 2)
      XCTAssertEqual(json[FlatSimpleArrayJWT.CodingKeys.testValue1.rawValue] as? String, testValue1)
    } else {
      XCTAssertEqual(json.count, 1)
    }
    XCTAssertEqual(json[FlatSimpleArrayJWT.CodingKeys.array.rawValue] as? [String], array.elements)
  }
}
