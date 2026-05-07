import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension UndisclosedJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    XCTAssertEqual(json[UndisclosedJWT.CodingKeys.key.rawValue] as? String, key)
  }
}
