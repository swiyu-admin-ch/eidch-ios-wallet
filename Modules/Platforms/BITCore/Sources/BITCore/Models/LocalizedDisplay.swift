/// Data model providing a Hash representation of the localized display
/// where the  key of the hash is the language in two letters form (ISO-639)
public struct LocalizedDisplay<T: Codable & Equatable>: Codable, Equatable {

  // MARK: Lifecycle

  public init(values: [String: T]) {
    self.values = values
  }

  public init?(from container: KeyedDecodingContainer<DynamicCodingKey>, withBaseKey baseKey: String) throws {
    for key in container.allKeys where key.stringValue == baseKey || key.stringValue.hasPrefix("\(baseKey)\(Self.separator)") {
      let language = key.stringValue.components(separatedBy: Self.separator).dropFirst().joined(separator: Self.separator)
      if let value = try? container.decode(T.self, forKey: key) {
        values[String(language)] = value
      }
    }

    if values.isEmpty {
      return nil
    }
  }

  // MARK: Public

  /// Retrieves the preferred display from a set of localized displays, considering the given language codes in their order.
  ///
  /// - Returns: The best matching display based on the given language codes or a fallback if available. Returns `nil` if no display is found.
  public func getPreferredDisplay(considering languageCodes: [String]) -> T? {
    languageCodes
      .lazy
      .compactMap { preferredValue(for: $0) }
      .first ?? values[""]
  }

  /// Returns all localized displays keyed by their locale identifier.
  public func getAllDisplays() -> [String: T] {
    values
  }

  // MARK: Private

  private static var separator: String {
    "#"
  }

  private var values = [String: T]()

  private func preferredValue(for languageCode: String) -> T? {
    if let exactMatch = values[languageCode] {
      return exactMatch
    }

    return values.first { key, _ in
      key.split(separator: "-").first.map(String.init) == languageCode
    }?.value
  }
}
