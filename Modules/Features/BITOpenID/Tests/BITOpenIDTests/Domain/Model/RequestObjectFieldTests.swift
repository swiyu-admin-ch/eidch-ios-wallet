import Foundation
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class RequestObjectFieldTests: XCTestCase {

  // MARK: Internal

  func testFieldIsMatching_OneVctPathAndMatchesFilter_ReturnsTrue() {
    let field = Field(path: [Self.mockPath1, Self.vctPath], filter: supportedFilter)

    let result = field.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFieldIsMatching_OneVctPathAndNotMatchesFilter_ReturnsFalse() {
    let field = Field(path: [Self.mockPath1, Self.vctPath], filter: supportedFilter)

    let result = field.isMatching(Self.mockOtherValue)

    XCTAssertFalse(result)
  }

  func testFieldIsMatching_OneVctPathButNoFilter_ReturnsTrue() {
    let field = Field(path: [Self.mockPath1, Self.vctPath], filter: nil)

    let result = field.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFieldIsMatching_NoVctPathAndNoFilter_ReturnsTrue() {
    let field = Field(path: [Self.mockPath1, Self.mockPath2], filter: nil)

    let result = field.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFieldIsMatching_NoVctPathButFilter_ReturnsTrue() {
    let field = Field(path: [Self.mockPath1, Self.mockPath2], filter: supportedFilter)

    let result = field.isMatching(Self.mockOtherValue)

    XCTAssertTrue(result)
  }

  func testFilterIsMatching_SupportedFilterMatches_ReturnsTrue() {
    let filter = Filter(const: Self.mockValue1, type: Self.stringType)

    let result = filter.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFilterIsMatching_SupportedFilterDoesNotMatch_ReturnsFalse() {
    let filter = Filter(const: Self.mockValue1, type: Self.stringType)

    let result = filter.isMatching(Self.mockOtherValue)

    XCTAssertFalse(result)
  }

  func testFilterIsMatching_NoStringType_ReturnsTrue() {
    let filter = Filter(const: Self.mockValue1, type: "otherType")

    let result = filter.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFilterIsMatching_NoConst_ReturnsTrue() {
    let filter = Filter(const: nil, type: Self.stringType)

    let result = filter.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFilterIsMatching_EmptyConst_ReturnsTrue() {
    let filter = Filter(const: "", type: Self.stringType)

    let result = filter.isMatching(Self.mockValue1)

    XCTAssertTrue(result)
  }

  func testFilterIsMatching_WrongValueType_ReturnsFalse() {
    let filter = Filter(const: Self.mockValue1, type: Self.stringType)

    let result = filter.isMatching(1)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private static let vctPath = "$.vct"
  private static let mockPath1 = "$.path1"
  private static let mockPath2 = "$.path2"
  private static let mockValue1 = "value1"
  private static let mockOtherValue = "otherValue"
  private static let stringType = "string"

  private let supportedFilter = Filter(const: mockValue1, type: stringType)

}
