import Foundation

extension String {

  // MARK: Public

  public func normalizedDid() -> String {
    hasPrefix(Self.didPrefix)
      ? String(dropFirst(Self.didPrefix.count))
      : self
  }

  // MARK: Private

  private static let didPrefix = "decentralized_identifier:"
}
