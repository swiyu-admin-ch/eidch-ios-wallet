import Foundation

extension JsonCanonicalizer {

  // MARK: Internal

  func canonicalizeDictionary(_ dict: [String: Any]) throws -> String {
    let sortedKeys = dict.keys.sorted(by: compareKeys)

    let keyValuePairs = try sortedKeys.compactMap { key -> String? in
      guard let value = dict[key] else { return nil }
      let escapedKey = escapeJSONString(key)
      let canonicalValue = try canonicalizeValue(value)
      return "\"\(escapedKey)\":\(canonicalValue)"
    }

    return "{\(keyValuePairs.joined(separator: ","))}"
  }

  // MARK: Private

  private func compareKeys(lhs: String, rhs: String) -> Bool {
    let lhsBytes = Array(lhs.utf8)
    let rhsBytes = Array(rhs.utf8)

    guard !lhsBytes.isEmpty && !rhsBytes.isEmpty else {
      return lhsBytes.count < rhsBytes.count
    }

    if let isSpecialCaseOrdering = handleSpecialCaseOrdering(lhs: lhsBytes[0], rhs: rhsBytes[0]) {
      return isSpecialCaseOrdering
    }

    return compareBytes(lhs: lhsBytes, rhs: rhsBytes)
  }

  /// Handles special case comparison between 4-byte UTF-8 and 3-byte UTF-8 with first byte 0xEF
  ///
  /// 4-byte UTF-8 (e.g., emoji) starts with 0xF0
  /// 3-byte UTF-8 with first byte 0xEF (e.g., certain special characters)
  /// 4-byte UTF-8 comes before 3-byte with 0xEF
  ///
  /// This method might need some more special case to handle like 2 bytes or other ranges
  private func handleSpecialCaseOrdering(lhs: UInt8, rhs: UInt8) -> Bool? {
    switch (lhs, rhs) {
    case (0xF0, 0xEF): true
    case (0xEF, 0xF0): false
    default: nil
    }
  }

  private func compareBytes(lhs: [UInt8], rhs: [UInt8]) -> Bool {
    let minLength = min(lhs.count, rhs.count)

    for i in 0..<minLength {
      if lhs[i] != rhs[i] {
        return lhs[i] < rhs[i]
      }
    }

    return lhs.count < rhs.count
  }

}
