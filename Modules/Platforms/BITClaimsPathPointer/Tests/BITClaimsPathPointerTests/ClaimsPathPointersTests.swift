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

  func testPointsAtSetOf_samePointer_returnsTrue() {
    for (_, pointer) in validPointerPairs {
      let result = pointer.pointsAtSetOf(pointer)
      XCTAssertTrue(result, "Wrong result for: \(pointer)")
    }
  }

  func testPointsAtSetOf_nullPointerOnIndex_returnsTrue() {
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
      let result = pointer.pointsAtSetOf(pointer)
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
      let result = pointer.pointsAtSetOf(targetPointer)
      XCTAssertFalse(result, "Wrong result for: \(pointer) and \(targetPointer)")
    }
  }

  func testPointsAtSetOf_secondPointerSmaller_returnsFalse() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([.string("name")], []),
      ([.index(0)], []),
      ([.null], []),
    ]
    for (pointer, targetPointer) in pointerPairs {
      let result = pointer.pointsAtSetOf(targetPointer)
      XCTAssertFalse(result, "Wrong result for: \(pointer) and \(targetPointer)")
    }
  }

  func testPointsAtSetOf_firstPointerSmaller_returnsTrue() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([], [.string("name")]),
      ([], [.index(0)]),
      ([], [.null]),
      ([.string("name")], [.string("name"), .string("name")]),
      ([.string("name")], [.string("name"), .index(0)]),
      ([.string("name")], [.string("name"), .null]),
      ([.index(0)], [.index(0), .string("name")]),
      ([.index(0)], [.index(0), .index(0)]),
      ([.index(0)], [.index(0), .null]),
      ([.null], [.index(0), .string("name")]),
      ([.null], [.index(0), .index(0)]),
      ([.null], [.index(0), .null]),
      ([.null], [.null, .string("name")]),
      ([.null], [.null, .index(0)]),
      ([.null], [.null, .null]),
    ]
    for (pointer, otherPointer) in pointerPairs {
      let result = pointer.pointsAtSetOf(otherPointer)
      XCTAssertTrue(result, "Wrong result for: \(pointer) and \(otherPointer)")
    }
  }

  func testPointsAtSetOf_firstPointerSmallerEnforcingLength_returnsFalse() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([], [.string("name")]),
      ([], [.index(0)]),
      ([], [.null]),
    ]
    for (pointer, targetPointer) in pointerPairs {
      let result = pointer.pointsAtSetOf(targetPointer, enforceLength: true)
      XCTAssertFalse(result, "Wrong result for: \(pointer) and \(targetPointer)")
    }
  }

  func testAllIndices_noIndex_returnsEmptyArray() {
    let pointers: [ClaimsPathPointer] = [
      [],
      [.null],
      [.string("name")],
      [.string("name"), .string("name")],
      [.null, .null],
    ]
    for pointer in pointers {
      let result = pointer.allIndices

      XCTAssertTrue(result.isEmpty, "Wrong result for: \(pointer)")
    }
  }

  func testAllIndices_indices_returnsAllIndices() {
    let pointerIndices: [(ClaimsPathPointer, [Int])] = [
      ([.index(0)], [0]),
      ([.index(0), .index(0)], [0, 0]),
      ([.index(0), .index(1)], [0, 1]),
      ([.null, .index(0)], [0]),
      ([.string("name"), .index(0), .null], [0]),
      ([.index(0), .null, .index(1)], [0, 1]),
    ]
    for (pointer, expectedIndices) in pointerIndices {
      let result = pointer.allIndices

      XCTAssertEqual(result, expectedIndices, "Wrong result for: \(pointer) and \(expectedIndices)")
    }
  }

  func testResolveNullElement_noNull_returnsAsIs() {
    let pointers: [ClaimsPathPointer] = [
      [],
      [.index(0)],
      [.string("name")],
      [.index(0), .index(0)],
      [.index(0), .string("name")],
    ]
    for pointer in pointers {
      let result = pointer.resolveNullElement(with: [0, 1])

      XCTAssertEqual(result, pointer, "Wrong result for: \(pointer)")
    }
  }

  func testResolveNullElement_noIndices_returnsAsIs() {
    let pointers: [ClaimsPathPointer] = [
      [.null],
      [.string("name"), .null],
    ]
    for pointer in pointers {
      let result = pointer.resolveNullElement(with: [])

      XCTAssertEqual(result, pointer, "Wrong result for: \(pointer)")
    }
  }

  func testResolveNullElement_nullAndIndices_returnsResolvedNullElements() {
    let pointerPairs: [(ClaimsPathPointer, ClaimsPathPointer)] = [
      ([.null], [.index(0)]),
      ([.null, .null], [.index(0), .index(1)]),
      ([.null, .null, .null], [.index(0), .index(1), .index(2)]),
      ([.string("name"), .null], [.string("name"), .index(0)]),
      ([.null, .index(3), .null], [.index(0), .index(3), .index(1)]),
    ]
    for (pointer, expectedPointer) in pointerPairs {
      let result = pointer.resolveNullElement(with: [0, 1, 2])

      XCTAssertEqual(result, expectedPointer, "Wrong result for: \(pointer), expected: \(expectedPointer)")
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
