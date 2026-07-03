import BITSwiyuSharedKMP
import Foundation

extension Heidi_utilValue {

  // MARK: Internal

  func jsonString() -> Swift.String {
    switch BITSwiyuSharedKMP.onEnum(of: self) {
    case .string(let stringValue):
      return stringValue.v1
    case .number(let numberValue):
      return codableNumber(from: numberValue.v1)
    case .boolean(let boolValue):
      return Swift.String(boolValue.v1)
    case .null:
      return "null"
    case .bytes(let bytesValue):
      return bytesValue.v1.toData().base64EncodedString()
    case .array(let arrayValue):
      let array = arrayValue.v1.map { $0.jsonString() }
      let data = (try? JSONEncoder().encode(array)) ?? Data()
      return Swift.String(decoding: data, as: UTF8.self)
    case .object(let objectValue):
      let dictionary = objectValue.v1.compactGroup { key, _ in
        key
      } valueTransform: { _, value in
        value.jsonString()
      }
      let data = (try? JSONEncoder().encode(dictionary)) ?? Data()
      return Swift.String(decoding: data, as: UTF8.self)
    case .orderedObject(let orderedObjectValue):
      return "\(orderedObjectValue.v1)"
    case .tag(let tagValue):
      let tag = Swift.String(tagValue.tag)
      let values = tagValue.value.map { $0.jsonString() }
      return "{\"tag\": \(tag), \"value\": \(values)}"
    }
  }

  // MARK: Private

  private func codableNumber(from number: Heidi_utilJsonNumber) -> Swift.String {
    switch BITSwiyuSharedKMP.onEnum(of: number) {
    case .integer(let integerValue):
      Swift.String(integerValue.v1)
    case .float(let floatValue):
      Swift.String(floatValue.v1)
    }
  }
}
