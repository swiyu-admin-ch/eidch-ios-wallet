import RegexBuilder

// MARK: - JsonPath

public struct JsonPath: Equatable, Decodable {

  // MARK: Lifecycle

  public init(rawString: String) throws {
    self.rawString = rawString
    childSegments = try Self.parseChildSegments(rawString)
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawString = try container.decode(String.self)
    try self.init(rawString: rawString)
  }

  // MARK: Public

  public let rawString: String

  public static func == (lhs: JsonPath, rhs: JsonPath) -> Bool {
    guard lhs.childSegments.count == rhs.childSegments.count else { return false }
    for (index, lhs) in lhs.childSegments.enumerated() {
      let rhs = rhs.childSegments[index]
      guard lhs == rhs || lhs == "[*]" && rhs.isIndexArray() || lhs.isIndexArray() && rhs == "[*]" else { return false }
    }
    return true
  }

  // MARK: Private

  private static let validJsonPathRegex = Regex {
    Anchor.startOfLine
    "$"
    OneOrMore(childSegment)
    Anchor.endOfLine
  }

  private static let childSegment = Regex {
    ChoiceOf {
      dotChildSegment
      bracketChildSegment
      arraySegment
    }
  }

  private static let dotChildSegment = Regex {
    "."
    dotNameCapture
  }

  private static let dotNameReference = Reference(String?.self)
  private static let dotNameCapture = Capture(as: dotNameReference) {
    childName
  } transform: {
    String($0)
  }

  private static let childName = Regex {
    One(
      CharacterClass(
        .anyOf("_"),
        "a"..."z",
        "A"..."Z"))
    ZeroOrMore(.word)
  }

  private static let quoteReference = Reference(Substring.self)
  private static let bracketChildSegment = Regex {
    "["
    Capture(.anyOf("\"'"), as: quoteReference) { $0 }
    bracketNameCapture
    quoteReference
    "]"
  }

  private static let bracketNameReference = Reference(String?.self)
  private static let bracketNameCapture = Capture(as: bracketNameReference) {
    childName
  } transform: {
    String($0)
  }

  private static let arrayReference = Reference(String?.self)
  private static let arraySegment = Regex {
    Capture(as: arrayReference) {
      "["
      ChoiceOf {
        OneOrMore(.digit)
        "*"
      }
      "]"
    } transform: {
      String($0)
    }
  }

  private let childSegments: [String]

  private static func parseChildSegments(_ rawString: String) throws -> [String] {
    guard (try? validJsonPathRegex.wholeMatch(in: rawString)) != nil else { throw OcaError.invalidJsonPath }
    return rawString.matches(of: childSegment).compactMap { match in
      match[dotNameReference] ?? match[bracketNameReference] ?? match[arrayReference]
    }
  }

}

extension String {
  fileprivate func isIndexArray() -> Bool {
    (try? indexArrayRegex.wholeMatch(in: self)) != nil
  }
}

private let indexArrayRegex = Regex {
  "["
  OneOrMore(.digit)
  "]"
}
