import Testing

/// A color scheme handed to a view model, paired with the display theme it must resolve to, so that
/// theme picking can be covered by a parameterized test instead of one test per scheme.
public struct ColorSchemeCase: Sendable, CustomTestStringConvertible {

  // MARK: Lifecycle

  public init(colorScheme: String, matchedTheme: String) {
    self.colorScheme = colorScheme
    self.matchedTheme = matchedTheme
  }

  // MARK: Public

  /// The first display of a bundle is the dark one, so an unmatched color scheme falls back to it.
  public static let all: [ColorSchemeCase] = [
    ColorSchemeCase(colorScheme: "other", matchedTheme: "dark"),
    ColorSchemeCase(colorScheme: "light", matchedTheme: "light"),
  ]

  public let colorScheme: String
  public let matchedTheme: String

  public var testDescription: String {
    "color scheme \(colorScheme)"
  }
}
