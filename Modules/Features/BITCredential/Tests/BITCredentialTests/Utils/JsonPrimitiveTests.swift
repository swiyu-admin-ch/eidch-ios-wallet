import Foundation
import XCTest
@testable import BITCredential

final class JsonPrimitiveTests: XCTestCase {

  // MARK: Internal

  func testInit_string_returnsString() throws {
    let primitive = try JsonPrimitive(decode("\"value\""))

    guard case .string("value") = primitive else {
      return XCTFail("Expected string")
    }
    XCTAssertEqual(primitive?.stringValue, "value")
  }

  func testInit_integer_returnsNumeric() throws {
    let primitive = try JsonPrimitive(decode("1"))

    guard case .numeric("1") = primitive else {
      return XCTFail("Expected numeric")
    }
    XCTAssertEqual(primitive?.stringValue, "1")
  }

  func testInit_double_returnsNumeric() throws {
    let primitive = try JsonPrimitive(decode("1.1"))

    guard case .numeric("1.1") = primitive else {
      return XCTFail("Expected numeric")
    }
    XCTAssertEqual(primitive?.stringValue, "1.1")
  }

  func testInit_true_returnsBool() throws {
    let primitive = try JsonPrimitive(decode("true"))

    guard case .bool(true) = primitive else {
      return XCTFail("Expected bool")
    }
    XCTAssertEqual(primitive?.stringValue, "true")
  }

  func testInit_false_returnsBool() throws {
    let primitive = try JsonPrimitive(decode("false"))

    guard case .bool(false) = primitive else {
      return XCTFail("Expected bool")
    }
    XCTAssertEqual(primitive?.stringValue, "false")
  }

  // MARK: Private

  private enum Value: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let bool = try? container.decode(Bool.self) {
        self = .bool(bool)
      } else if let int = try? container.decode(Int.self) {
        self = .int(int)
      } else if let double = try? container.decode(Double.self) {
        self = .double(double)
      } else if let string = try? container.decode(String.self) {
        self = .string(string)
      } else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoding Error")
      }
    }

    // MARK: Internal

    var value: Any {
      switch self {
      case .string(let string): string
      case .int(let int): int
      case .double(let double): double
      case .bool(let bool): bool
      }
    }
  }

  private func decode(_ rawValue: String) throws -> Any {
    let data = Data(rawValue.utf8)
    return try JSONDecoder().decode(Value.self, from: data).value
  }

}
