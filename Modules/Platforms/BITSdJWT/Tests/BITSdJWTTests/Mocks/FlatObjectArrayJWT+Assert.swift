// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension FlatObjectArrayJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    let jsonArray = json[FlatObjectArrayJWT.CodingKeys.array.rawValue] as! [JSON]

    XCTAssertEqual(jsonArray.count, 2)
    XCTAssertEqual(jsonArray[0][FlatObjectArrayJWT.Nested.CodingKeys.testKey1.rawValue] as? String, array[0].testKey1)
    XCTAssertEqual(jsonArray[0][FlatObjectArrayJWT.Nested.CodingKeys.testKey2.rawValue] as? String, array[0].testKey2)

    XCTAssertEqual(jsonArray[1][FlatObjectArrayJWT.Nested.CodingKeys.testKey1.rawValue] as? String, array[1].testKey1)
    XCTAssertEqual(jsonArray[1][FlatObjectArrayJWT.Nested.CodingKeys.testKey2.rawValue] as? String, array[1].testKey2)
  }
}
