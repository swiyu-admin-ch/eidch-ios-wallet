import Foundation

extension String {

  // MARK: Internal

  func normalizedDid() -> String? {
    let normalizedDid = hasPrefix(Self.didPrefix)
      ? String(dropFirst(Self.didPrefix.count))
      : self

    guard
      let regex = try? Regex(Self.regex),
      !normalizedDid.matches(of: regex).isEmpty
    else {
      return nil
    }

    return normalizedDid
  }

  // MARK: Private

  private static let regex = "^did:[a-z0-9]+:[a-zA-Z0-9.\\-_:]+$"
  private static let didPrefix = "decentralized_identifier:"
}
