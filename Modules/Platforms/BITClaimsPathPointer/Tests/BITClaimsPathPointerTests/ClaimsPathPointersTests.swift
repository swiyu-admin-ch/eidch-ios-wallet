import Foundation
import XCTest
@testable import BITClaimsPathPointer

final class ClaimsPathPointersTests: XCTestCase {

  // MARK: Internal

  func testInit_valid_returnsPointer() {
    for (rawPointer, expectedPointer) in validPointerPairs {
      let pointer = ClaimsPathPointer(rawPointer)

      XCTAssertEqual(pointer, expectedPointer, "Wrong result for: \(rawPointer)")
    }
  }

  func testInit_invalid_returnsNil() {
    let pointers = [
      "",
      "name",
      "[name]",
      "[\"name\" null]",
      "{\"name\": null}",
    ]

    for rawPointer in pointers {
      let pointer = ClaimsPathPointer(rawPointer)

      XCTAssertNil(pointer)
    }
  }

  func testStringValue_valid_returnsString() {
    for (expectedRaw, pointer) in validPointerPairs {
      let result = pointer.stringValue

      XCTAssertEqual(result, expectedRaw, "Wrong result for: \(pointer)")
    }
  }

  func testIsPointing_samePointer_returnsTrue() {
    for (_, pointer) in validPointerPairs {
      let result = pointer.isPointing(at: pointer)
      XCTAssertTrue(result, "Wrong result for: \(pointer)")
    }
  }

  func testIsPointing_nullPointerOnIndex_returnsTrue() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([.null], [.index(0)]),
      ([.null], [.index(1)]),
      ([.null, .null], [.index(0), .index(0)]),
      ([.null, .null], [.null, .index(0)]),
      ([.null, .null], [.index(0), .null]),
      ([.null, .string("name")], [.index(0), .string("name")]),
      ([.string("name"), .null], [.string("name"), .index(0)]),
    ]
    for (_, pointer) in pointerPairs {
      let result = pointer.isPointing(at: pointer)
      XCTAssertTrue(result, "Wrong result for: \(pointer)")
    }
  }

  func testIsPointing_notPointing_returnsFalse() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([.string("name")], [.string("otherName")]),
      ([.string("name")], [.index(1)]),
      ([.string("name")], [.null]),
      ([.index(1)], [.index(0)]),
      ([.index(1)], [.string("name")]),
      ([.index(1)], [.null]),
      ([.null], [.string("name")]),
      ([.string("name"), .string("name")], [.string("otherName"), .string("otherName")]),
      ([.string("name"), .string("name")], [.string("name"), .string("otherName")]),
      ([.string("name"), .string("name")], [.string("otherName"), .string("name")]),
      ([.string("name"), .string("name")], [.string("name"), .index(1)]),
      ([.string("name"), .string("name")], [.index(1), .string("name")]),
      ([.string("name"), .string("name")], [.string("name"), .null]),
      ([.string("name"), .string("name")], [.null, .string("name")]),
      ([.index(1), .index(1)], [.index(0), .index(0)]),
      ([.index(1), .index(1)], [.index(1), .index(0)]),
      ([.index(1), .index(1)], [.index(0), .index(1)]),
      ([.index(1), .index(1)], [.null, .index(1)]),
      ([.index(1), .index(1)], [.index(1), .null]),
      ([.index(1), .index(1)], [.null, .null]),
      ([.index(1), .string("name")], [.index(1), .index(1)]),
      ([.index(1), .string("name")], [.index(1), .string("otherName")]),
      ([.index(1), .string("name")], [.index(0), .string("name")]),
      ([.index(1), .string("name")], [.index(1), .null]),
      ([.index(1), .string("name")], [.null, .string("name")]),
      ([.index(1), .null], [.index(1), .string("name")]),
      ([.index(1), .null], [.null, .null]),
      ([.string("name"), .index(1)], [.index(1), .string("name")]),
      ([.string("name"), .index(1)], [.string("name"), .index(0)]),
      ([.string("name"), .index(1)], [.string("otherName"), .index(1)]),
      ([.string("name"), .index(1)], [.string("name"), .null]),
      ([.null, .null], [.string("name"), .string("name")]),
      ([.null, .null], [.index(1), .string("name")]),
      ([.null, .null], [.string("name"), .index(1)]),
      ([.null, .string("name")], [.null, .string("otherName")]),
      ([.null, .string("name")], [.null, .index(1)]),
      ([.null, .string("name")], [.index(0), .string("otherName")]),
      ([.null, .index(1)], [.null, .null]),
      ([.null, .index(1)], [.null, .string("name")]),
    ]
    for (pointer, targetPointer) in pointerPairs {
      let result = pointer.isPointing(at: targetPointer)
      XCTAssertFalse(result, "Wrong result for: \(pointer) and \(targetPointer)")
    }
  }

  // MARK: Private

  private let validPointerPairs: [(String, ClaimsPathPointer)] = [
    ("[]", []),
    ("[\"name\"]", [.string("name")]),
    ("[null]", [.null]),
    ("[1]", [.index(1)]),
    ("[\"name\",null]", [.string("name"), .null]),
    ("[\"name\",1]", [.string("name"), .index(1)]),
    ("[\"name\",null,1]", [.string("name"), .null, .index(1)]),
    ("[null,null]", [.null, .null]),
    ("[0,1]", [.index(0), .index(1)]),
    ("[null,1]", [.null, .index(1)]),
    ("[1,null]", [.index(1), .null]),
  ]
}
