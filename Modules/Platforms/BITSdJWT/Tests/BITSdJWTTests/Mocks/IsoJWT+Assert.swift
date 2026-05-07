import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension IsoJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    XCTAssertEqual(json[IsoJWT.CodingKeys.date.rawValue] as? String, date?.formatted(.iso8601))
  }
}
