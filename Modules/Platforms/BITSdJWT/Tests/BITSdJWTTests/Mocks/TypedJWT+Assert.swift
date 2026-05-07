import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension TypedJWT {
  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 3)
    XCTAssertEqual(json[TypedJWT.CodingKeys.number.rawValue] as? Int, number)
    XCTAssertEqual(json[TypedJWT.CodingKeys.boolean.rawValue] as? Bool, boolean)
    XCTAssertNil(json[TypedJWT.CodingKeys.null.rawValue] as? Int)
  }
}
