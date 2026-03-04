import Foundation
import XCTest
@testable import BITCore

final class CodableValueTests: XCTestCase {

  // MARK: Internal

  func testStringEncodingDecoding() throws {
    let originalValue = "Hello, World!"
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .string(originalValue))
  }

  func testIntEncodingDecoding() throws {
    let originalValue = 42
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .int(originalValue))
  }

  func testDoubleEncodingDecoding() throws {
    let originalValue = 3.14
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .double(originalValue))
  }

  func testBoolEncodingDecoding() throws {
    let originalValue = true
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .bool(originalValue))
  }

  func testArrayEncodingDecoding() throws {
    let value1 = "apple"
    let value2 = 123
    let value3 = true
    let originalValue: [Any] = [value1, value2, value3]
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .array([.string(value1), .int(value2), .bool(value3)]))
  }

  func testDictionaryEncodingDecoding() throws {
    let key1 = "name"
    let value1 = "John"
    let key2 = "age"
    let value2 = 30
    let key3 = "isStudent"
    let value3 = false
    let originalValue: [String: Any] = [key1: value1, key2: value2, key3: value3]
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .dictionary([key1: .string(value1), key2: .int(value2), key3: .bool(value3)]))
  }

  func testUnsupportedTypeThrowsError() throws {
    let originalValue = NSNull()
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertNil(codableValue)
  }

  func testInitWithString() throws {
    let originalValue = "Hello, World!"
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .string(originalValue))
    XCTAssertTrue(codableValue?.isString ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithInt() throws {
    let originalValue = 42
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .int(originalValue))
    XCTAssertTrue(codableValue?.isInt ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithIntAsFakeBool() throws {
    let originalValue = 1
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .int(originalValue))
    XCTAssertTrue(codableValue?.isInt ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithIntAsFakeBool0() throws {
    let originalValue = 0
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .int(originalValue))
    XCTAssertTrue(codableValue?.isInt ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithDouble() throws {
    let originalValue = 3.14
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .double(originalValue))
    XCTAssertTrue(codableValue?.isDouble ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithBool() throws {
    let originalValue = true
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .bool(originalValue))
    XCTAssertTrue(codableValue?.isBool ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithBoolAsString() throws {
    let originalValue = "true"
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertTrue(codableValue?.isString ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
  }

  func testInitWithArray() throws {
    let originalValue = ["apple", 123, true] as [Any]
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .array([.string("apple"), .int(123), .bool(true)]))
    XCTAssertTrue(codableValue?.isArray ?? false)

    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isDictionary ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
  }

  func testInitWithDictionary() throws {
    let originalValue = ["name": "John", "age": 30, "isStudent": false] as [String: Any]
    let codableValue = try CodableValue(anyValue: originalValue)
    XCTAssertEqual(codableValue, .dictionary(["name": .string("John"), "age": .int(30), "isStudent": .bool(false)]))
    XCTAssertTrue(codableValue?.isDictionary ?? false)

    XCTAssertFalse(codableValue?.isArray ?? true)
    XCTAssertFalse(codableValue?.isInt ?? true)
    XCTAssertFalse(codableValue?.isDouble ?? true)
    XCTAssertFalse(codableValue?.isBool ?? true)
    XCTAssertFalse(codableValue?.isString ?? true)
  }

  func testInitWithUnsupportedTypeThrowsError() throws {
    let invalidValue = CustomStruct(value: "invalid")
    let codableValue = try CodableValue(anyValue: invalidValue)
    XCTAssertNil(codableValue)
  }

  // MARK: Private

  /// Helper struct for testing unsupported type
  private struct CustomStruct {
    let value: String
  }

}
