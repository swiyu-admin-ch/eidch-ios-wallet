import Foundation
import Spyable

// MARK: - JsonCanonicalizerError

public enum JsonCanonicalizerError: Error {
  case invalidJsonInput(Error)
  case cannotConvertJsonStringToData
  case cannotConvertDataToString
  case infiniteNumberNotPermitted
  case unsupportedType
}

// MARK: - JsonCanonicalizerProtocol

/// Protocol for JSON canonicalization according to RFC-8785
/// https://www.rfc-editor.org/rfc/rfc8785.html
@Spyable
public protocol JsonCanonicalizerProtocol {
  func canonicalize(data: Data) throws -> Data
  func canonicalize(jsonString: String) throws -> Data
  func canonicalizeToString(_ jsonString: String) throws -> String
}

extension JsonCanonicalizerProtocol {
  public func canonicalize(jsonString: String) throws -> Data {
    guard let data = jsonString.data(using: .utf8) else {
      throw JsonCanonicalizerError.cannotConvertJsonStringToData
    }
    return try canonicalize(data: data)
  }

  public func canonicalizeToString(_ jsonString: String) throws -> String {
    let data = try canonicalize(jsonString: jsonString)
    guard let result = String(data: data, encoding: .utf8) else {
      throw JsonCanonicalizerError.cannotConvertDataToString
    }
    return result
  }
}

// MARK: - JsonCanonicalizer

public struct JsonCanonicalizer: JsonCanonicalizerProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  // MARK: - Public Methods

  public func canonicalize(data: Data) throws -> Data {
    var jsonObject: Any

    do {
      jsonObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
    } catch {
      throw JsonCanonicalizerError.invalidJsonInput(error)
    }

    let canonicalJsonString = try canonicalizeValue(jsonObject)

    guard let resultData = canonicalJsonString.data(using: .utf8) else {
      throw JsonCanonicalizerError.cannotConvertJsonStringToData
    }
    return resultData
  }

  // MARK: Internal

  // MARK: - Private Methods

  /// Generates canonical JSON for any value
  func canonicalizeValue(_ value: Any) throws -> String {
    switch value {
    case let dict as [String: Any]:
      return try canonicalizeDictionary(dict)
    case let array as [Any]:
      return try canonicalizeArray(array)
    case let number as NSNumber:
      return try canonicalizeNumber(number)
    case let string as String:
      return try canonicalizeString(string)
    case is NSNull:
      return "null"
    default:
      throw JsonCanonicalizerError.unsupportedType
    }
  }

}
