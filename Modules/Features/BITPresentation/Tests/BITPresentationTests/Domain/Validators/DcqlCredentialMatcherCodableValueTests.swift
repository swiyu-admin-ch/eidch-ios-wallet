import BITSwiyuSharedKMP
import XCTest
@testable import BITCore
@testable import BITPresentation

final class DcqlCredentialMatcherCodableValueTests: XCTestCase {

  func testCodableValue_MapsStringAndBool() {
    XCTAssertEqual(DcqlCodableValueMapper.codableValue(from: Heidi_utilValue.String(v1: "Ada")), .string("Ada"))
    XCTAssertEqual(DcqlCodableValueMapper.codableValue(from: Heidi_utilValue.Boolean(v1: true)), .bool(true))
  }

  func testCodableValue_MapsNumbers() {
    let intValue = Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Integer(v1: 42))
    let floatValue = Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Float(v1: 3.14))

    XCTAssertEqual(DcqlCodableValueMapper.codableValue(from: intValue), .int(42))
    XCTAssertEqual(DcqlCodableValueMapper.codableValue(from: floatValue), .double(3.14))
  }

  func testCodableValue_MapsArrayAndObject() {
    let arrayValue = Heidi_utilValue.Array(v1: [
      Heidi_utilValue.String(v1: "one"),
      Heidi_utilValue.Boolean(v1: false),
    ])
    let objectValue = Heidi_utilValue.Object(v1: [
      "name": Heidi_utilValue.String(v1: "Fritz"),
      "age": Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Integer(v1: 12)),
    ])

    XCTAssertEqual(
      DcqlCodableValueMapper.codableValue(from: arrayValue),
      .array([.string("one"), .bool(false)]))
    XCTAssertEqual(
      DcqlCodableValueMapper.codableValue(from: objectValue),
      .dictionary([
        "name": .string("Fritz"),
        "age": .int(12),
      ]))
  }

  func testCodableStringKey_MapsScalarValues() {
    XCTAssertEqual(DcqlCodableValueMapper.codableStringKey(from: Heidi_utilValue.String(v1: "key")), "key")
    XCTAssertEqual(
      DcqlCodableValueMapper.codableStringKey(from: Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Integer(v1: 7))),
      "7")
    XCTAssertEqual(DcqlCodableValueMapper.codableStringKey(from: Heidi_utilValue.Boolean(v1: true)), "true")
  }

}
