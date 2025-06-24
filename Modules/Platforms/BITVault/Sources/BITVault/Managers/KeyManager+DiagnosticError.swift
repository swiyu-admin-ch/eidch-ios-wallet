import Foundation

// MARK: - KeyManager.DiagnosticErrorHelper

extension KeyManager {
  struct DiagnosticErrorHelper {

    // MARK: Internal

    static func diagnostic(for query: [String: Any], error: CFError) -> String {
      let accessControlDescription = String(describing: query[kSecAttrAccessControl as String])
      let isValid = isMatching(raw: accessControlDescription)
      let missingFlags = missingFlags(in: accessControlDescription)
        .sorted()
        .joined(separator: ", ")
        .ifEmpty("none")

      return """
      Key generation failed:
      ▸ AccessControl: \(accessControlDescription)
      ▸ AccessControl Matches Expected: \(isValid)
      ▸ Missing Flags: \(missingFlags)
      ▸ RawError: \(error)
      """
    }

    // MARK: Private

    private static let expectedFlags: Set<String> = [
      "prp(true)", // .privateKeyUsage
      "oa(true)", // .applicationPassword
      "ock(true)", // kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      "odel(true)", // .devicePasscode or biometric
      "aku", // system-defined Secure Enclave usage
      "okd(true)", // device-only key storage
      "osgn(true)", // signature operation usage
    ]

    private static func isMatching(raw: String) -> Bool {
      missingFlags(in: raw).isEmpty
    }

    private static func missingFlags(in raw: String) -> Set<String> {
      let found = parseFlags(from: raw)
      return expectedFlags.subtracting(found)
    }

    private static func parseFlags(from raw: String) -> Set<String> {
      guard let start = raw.range(of: ":"), let end = raw.range(of: ">") else { return [] }
      let content = raw[start.upperBound..<end.lowerBound]
      return Set(content.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) })
    }
  }
}

extension String {
  fileprivate func ifEmpty(_ defaultValue: String) -> String {
    isEmpty ? defaultValue : self
  }
}
