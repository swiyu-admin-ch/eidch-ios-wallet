import BITCore
import Foundation

struct DisclosableArray<T: Codable & Equatable>: Codable, Equatable {

  // MARK: Lifecycle

  init(_ elements: [T]) {
    self.elements = elements
  }

  init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var decodedElements = [T]()
    while !container.isAtEnd {
      if let element = try? container.decode(T.self) {
        decodedElements.append(element)
      } else {
        let nestedContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self)
        if nestedContainer?.allKeys.contains(where: { $0.stringValue == "..." }) == false {
          try decodedElements.append(container.decode(T.self))
        }
      }
    }
    elements = decodedElements
  }

  // MARK: Internal

  let elements: [T]
}
