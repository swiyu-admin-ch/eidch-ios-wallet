import Foundation
import XCTest
@testable import BITClaimsPathPointer

final class ClaimsPathPointersGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    generator = ClaimsPathPointersGenerator()
  }

  func testCallAsFunction_generates() {
    let result = generator(for: claims)

    let expectedResult: [ClaimsPathPointer] = [
      [.string("name")],
      [.string("address"), .string("street_address")],
      [.string("address"), .string("locality")],
      [.string("address"), .string("postal_code")],
      [.string("degrees"), .index(0), .string("type")],
      [.string("degrees"), .index(0), .string("university")],
      [.string("degrees"), .index(1), .string("type")],
      [.string("degrees"), .index(1), .string("university")],
      [.string("nationalities"), .index(0)],
      [.string("nationalities"), .index(1)],
      [.string("array_in_array"), .index(0), .index(0)],
      [.string("array_in_array"), .index(0), .index(1)],
      [.string("array_in_array"), .index(1), .index(0)],
      [.string("array_in_array"), .index(1), .index(1)],
    ]

    XCTAssertEqual(expectedResult.map(\.stringValue).sorted(), result.map(\.stringValue).sorted())
  }

  // MARK: Private

  private let claims: [String: Any] = [
    "name": "Arthur Dent",
    "address": [
      "street_address": "42 Market Street",
      "locality": "Milliways",
      "postal_code": "12345",
    ],
    "degrees": [
      [
        "type": "Bachelor of Science",
        "university": "University of Betelgeuse",
      ],
      [
        "type": "Master of Science",
        "university": "University of Betelgeuse",
      ],
    ],
    "nationalities": ["British", "Betelgeusian"],
    "array_in_array": [
      [1, 2], [3, 4],
    ],
  ]

  private var generator = ClaimsPathPointersGenerator()
}
