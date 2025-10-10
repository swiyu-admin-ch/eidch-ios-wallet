import Foundation

extension Sequence {
  public func asyncFilter(_ isIncluded: (Self.Element) async throws -> Bool) async rethrows -> [Self.Element] {
    var values = [Self.Element]()
    for element in self where try await isIncluded(element) {
      values.append(element)
    }
    return values
  }
}
