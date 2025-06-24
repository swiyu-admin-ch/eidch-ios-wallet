import Foundation
import RegexBuilder

extension URL {

  public var queryParameters: [String: String]? {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let items = components.queryItems
    else { return nil }
    return items.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
  }

  public var isValidHttpUrl: Bool {
    let pattern = #/^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/#
    let regex = Regex(pattern)
    return absoluteString.firstMatch(of: regex) != nil
  }

  /// A Boolean that is true if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var isDataURL: Bool {
    (try? dataURLRegex.wholeMatch(in: absoluteString)) != nil
  }

  /// The media type component of the URL if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var mediaType: String? {
    guard let match = try? dataURLRegex.wholeMatch(in: absoluteString) else { return nil }
    return match[mediaTypeReference]
  }

  /// The data component of the URL as a string if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var dataURLDataString: String? {
    guard let match = try? dataURLRegex.wholeMatch(in: absoluteString) else { return nil }
    return match[dataReference]
  }

  /// The data component of the URL if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var dataURLData: Data? {
    guard let match = try? dataURLRegex.wholeMatch(in: absoluteString) else { return nil }
    let dataString = match[dataReference]
    return if match[base64Reference] != nil {
      Data(base64Encoded: dataString)
    } else {
      dataString.data(using: .utf8)
    }
  }
}

private let mediaTypeReference = Reference(String?.self)
private let mediaTypeCapture = Capture(as: mediaTypeReference) {
  OneOrMore(CharacterClass(.word, .anyOf("-")))
  "/"
  OneOrMore(CharacterClass(.word, .anyOf("-+.")))
} transform: {
  String($0)
}

private let dataReference = Reference(String.self)
private let dataCapture = Capture(as: dataReference) {
  ZeroOrMore(.any)
} transform: {
  String($0)
}

private let base64Reference = Reference(String?.self)
private let base64Capture = Capture(as: base64Reference) {
  ";base64"
} transform: {
  String($0)
}

private let dataURLRegex = Regex {
  "data:"
  Optionally(mediaTypeCapture)
  Optionally(base64Capture)
  ","
  dataCapture
}
