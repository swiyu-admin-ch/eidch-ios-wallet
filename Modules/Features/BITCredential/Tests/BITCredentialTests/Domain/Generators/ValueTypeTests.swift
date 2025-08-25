import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITOca

final class ValueTypeTests: XCTestCase {

  // MARK: Internal

  func testInit_text_returnsString() throws {
    let attributeMock = createAttribute(type: .text)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  func testInit_boolean_returnsBoolean() throws {
    let attributeMock = createAttribute(type: .boolean)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .boolean)
  }

  func testInit_binaryPNG_returnsImagePng() throws {
    let attributeMock = createAttribute(type: .binary, format: "image/png", encoding: .base64)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .imagePng)
  }

  func testInit_binaryJPG_returnsImageJpg() throws {
    let attributeMock = createAttribute(type: .binary, format: "image/jpeg", encoding: .base64)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .imageJpg)
  }

  func testInit_binaryPNGNoEncoding_returnsString() throws {
    let attributeMock = createAttribute(type: .binary, format: "image/png")

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  func testInit_binaryPNGInvalidEncoding_returnsString() throws {
    let attributeMock = createAttribute(type: .binary, format: "image/jpeg", encoding: .unknown(rawString: "UTF-8"))

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  func testInit_binaryNoFormat_returnsString() throws {
    let attributeMock = createAttribute(type: .binary, encoding: .base64)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  func testInit_array_returnsString() throws {
    let attributeMock = createAttribute(type: .array(type: .boolean))

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  func testInit_dateTime_returnsString() throws {
    let attributeMock = createAttribute(type: .dateTime)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .dateTime)
  }

  func testInit_numeric_returnsString() throws {
    let attributeMock = createAttribute(type: .numeric)

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .numeric)
  }

  func testInit_reference_returnsString() throws {
    let attributeMock = createAttribute(type: .reference(digest: "digest"))

    let result = ValueType(attributeMock)

    XCTAssertEqual(result, .string)
  }

  // MARK: Private

  private func createAttribute(type: AttributeType, format: String? = nil, encoding: CharacterEncoding? = nil) -> OverlayBundleAttribute {
    OverlayBundleAttribute(captureBaseDigest: "digest", name: "name", attributeType: type, characterEncoding: encoding, format: format)
  }
}
