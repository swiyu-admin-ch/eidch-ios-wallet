// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension RecursiveJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    let nested = json[RecursiveJWT.CodingKeys.key.rawValue] as! JSON
    XCTAssertEqual(nested.count, 1)
    XCTAssertEqual(nested[RecursiveJWT.Nested.CodingKeys.key.rawValue] as? String, key?.key)
  }
}
