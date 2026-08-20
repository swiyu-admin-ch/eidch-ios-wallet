import Foundation

extension String {

  // MARK: Public

  public func normalizedDid() -> String {
    hasPrefix(Self.didPrefix)
      ? String(dropFirst(Self.didPrefix.count))
      : self
  }

  // MARK: Internal

  var matchesDid: Bool {
    guard let regex = try? Regex(Self.regex) else { return false }
    return !matches(of: regex).isEmpty
  }

  // MARK: Private

  private static let regex = "^did:[a-z0-9]+:[a-zA-Z0-9.\\-_:]+$"
  private static let didPrefix = "decentralized_identifier:"
}
