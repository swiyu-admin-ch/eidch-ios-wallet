import Foundation

extension JsonCanonicalizer {
  func canonicalizeString(_ string: String) throws -> String {
    let normalizedString = string.decomposedStringWithCanonicalMapping
    return "\"\(escapeJSONString(normalizedString))\""
  }
}
