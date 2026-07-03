import Foundation
import XCTest
@testable import BITCore

final class ArrayUniqueExtensionsTests: XCTestCase {

  func testUniqued_uniqueElements_returnsSame() {
    let array = [1, 2, 3]

    let result = array.uniqued()

    XCTAssertEqual(result, array)
  }

  func testUniqued_duplicateElements_returnsOnlyUniqueElements() {
    let array = [1, 2, 3, 2, 1]

    let result = array.uniqued()

    XCTAssertEqual(result, [1, 2, 3])
  }

  func testUniqued_duplicateElements_returnsOnlyUniqueElementsInOrder() {
    let array = [1, 2, 2, 1, 3, 2, 1]

    let result = array.uniqued()

    XCTAssertEqual(result, [1, 2, 3])
  }

  func testUniqued_empty_returnsEmpty() {
    let array = [Int]()

    let result = array.uniqued()

    XCTAssertEqual(result, [])
  }
}
