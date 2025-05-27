import Foundation

extension JsonCanonicalizer {

  func canonicalizeArray(_ array: [Any]) throws -> String {
    let items = try array.map { try canonicalizeValue($0) }
    return "[\(items.joined(separator: ","))]"
  }

}
