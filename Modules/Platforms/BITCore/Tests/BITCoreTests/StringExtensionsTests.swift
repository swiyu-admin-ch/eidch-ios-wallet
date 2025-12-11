import Foundation
import XCTest
@testable import BITCore

final class StringExtensionsTests: XCTestCase {

  func testStringToJsonObject_bool_true() throws {
    let string = "true"
    let anyObject = try string.toJsonObject()

    XCTAssertNil(anyObject as? String)
    XCTAssertNil(anyObject as? Int)
    XCTAssertNotNil(anyObject as? Bool)
    XCTAssertEqual(anyObject as? Bool, true)
  }

  func testStringToJsonObject_bool_false() throws {
    let string = "false"
    let anyObject = try string.toJsonObject()

    XCTAssertNil(anyObject as? String)
    XCTAssertNil(anyObject as? Int)
    XCTAssertNotNil(anyObject as? Bool)
    XCTAssertEqual(anyObject as? Bool, false)
  }

  func testStringToJsonObject_int_1() throws {
    let string = "1"
    let anyObject = try string.toJsonObject()

    XCTAssertNil(anyObject as? String)
    XCTAssertNotNil(anyObject as? Bool) // 1 may also be considered as true
    XCTAssertNotNil(anyObject as? Int)
    XCTAssertEqual(anyObject as? Int, 1)
  }

  func testStringToJsonObject_int_0() throws {
    let string = "0"
    let anyObject = try string.toJsonObject()

    XCTAssertNil(anyObject as? String)
    XCTAssertNotNil(anyObject as? Bool) // 0 may also be considered as true
    XCTAssertNotNil(anyObject as? Int)
    XCTAssertEqual(anyObject as? Int, 0)
  }
}
