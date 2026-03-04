import BITCore
import BITSwiyuSharedKMP
import Foundation

// MARK: - DcqlCodableValueMapper

/// Helper conversions for mapping KMP DCQL values into `CodableValue` trees.
enum DcqlCodableValueMapper {

  // MARK: Internal

  /// Entry point: converts a shared KMP `Value` into a Swift `CodableValue`.
  /// - Parameter value: The KMP value to transform.
  /// - Returns: The corresponding `CodableValue`, or `nil` for explicit `null` values.
  static func codableValue(from value: Heidi_utilValue) -> CodableValue? {
    switch BITSwiyuSharedKMP.onEnum(of: value) {
    case .string(let stringValue):
      return .string(stringValue.v1)
    case .number(let numberValue):
      return codableNumber(from: numberValue.v1)
    case .boolean(let boolValue):
      return .bool(boolValue.v1)
    case .null:
      return nil
    case .array(let arrayValue):
      let values = arrayValue.v1.map { element in
        codableValue(from: element)
      }
      return .array(values)
    case .object(let objectValue):
      return .dictionary(codableDictionary(from: objectValue.v1))
    case .orderedObject(let orderedObjectValue):
      return .dictionary(codableDictionary(from: orderedObjectValue.v1.entries))
    case .bytes(let bytesValue):
      return .string(bytesValue.v1.toData().base64EncodedString())
    case .tag(let tagValue):
      let tag = CodableValue.string(String(tagValue.tag))
      let values = tagValue.value.map { element in
        codableValue(from: element)
      }
      return .dictionary([
        "tag": tag,
        "value": .array(values),
      ])
    }
  }

  static func codableStringKey(from value: Heidi_utilValue) -> String? {
    switch BITSwiyuSharedKMP.onEnum(of: value) {
    case .string(let stringValue):
      stringValue.v1
    case .number(let numberValue):
      switch BITSwiyuSharedKMP.onEnum(of: numberValue.v1) {
      case .integer(let integerValue):
        String(integerValue.v1)
      case .float(let floatValue):
        String(floatValue.v1)
      }
    case .boolean(let boolValue):
      boolValue.v1 ? "true" : "false"
    case .array,
         .bytes,
         .null,
         .object,
         .orderedObject,
         .tag:
      nil
    }
  }

  // MARK: Private

  private static func codableNumber(from number: Heidi_utilJsonNumber) -> CodableValue {
    switch BITSwiyuSharedKMP.onEnum(of: number) {
    case .integer(let integerValue):
      .int(Int(integerValue.v1))
    case .float(let floatValue):
      .double(floatValue.v1)
    }
  }

  private static func codableDictionary(from values: [String: Heidi_utilValue]) -> [String: CodableValue?] {
    values.reduce(into: [String: CodableValue?]()) { result, entry in
      result[entry.key] = codableValue(from: entry.value)
    }
  }

  private static func codableDictionary(from entries: [Heidi_utilMapEntry]) -> [String: CodableValue?] {
    entries.reduce(into: [String: CodableValue?]()) { result, entry in
      guard let key = codableStringKey(from: entry.key) else { return }
      result[key] = codableValue(from: entry.value)
    }
  }
}
