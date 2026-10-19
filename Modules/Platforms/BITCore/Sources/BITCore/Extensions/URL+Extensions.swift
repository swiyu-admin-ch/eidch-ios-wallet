import Factory
import Foundation
import RegexBuilder

extension URL {

  // MARK: Public

  public var queryParameters: [String: String]? {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let items = components.queryItems
    else { return nil }
    return items.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
  }

  public var isValidHttpUrl: Bool {
    let maxHttpUrlLength = Container.shared.maxHttpUrlLength()
    guard absoluteString.count <= maxHttpUrlLength else { return false }
    let regex: TimeLimitedRegex = #"https?://(?:www\.)?(?:[-a-zA-Z0-9@:%_\+~#=]{1,256}\.)+[a-zA-Z0-9()]+\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)"#
    return (try? regex.wholeMatch(in: absoluteString)) ?? false
  }

  /// A Boolean that is true if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var isDataURL: Bool {
    parsedDataURL != nil
  }

  /// The media type component of the URL if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var mediaType: String? {
    parsedDataURL?.mediaType
  }

  /// The data component of the URL as a string if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var dataURLDataString: String? {
    parsedDataURL?.data
  }

  /// The data component of the URL if the URL conforms to RFC 2397 (data URL); otherwise nil.
  public var dataURLData: Data? {
    guard let parsed = parsedDataURL else { return nil }
    return parsed.isBase64 ? Data(base64Encoded: parsed.data) : parsed.data.data(using: .utf8)
  }

  public var deletingPathAndQuery: URL? {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.port = port
    return components.url
  }

  // MARK: Private

  private struct DataURLComponents {
    let mediaType: String?
    let data: String
    let isBase64: Bool
  }

  private var parsedDataURL: DataURLComponents? {
    let mediaTypeReference = Reference(String?.self)
    let mediaTypeCapture = Capture(as: mediaTypeReference) {
      OneOrMore(CharacterClass(.word, .anyOf("-")))
      "/"
      OneOrMore(CharacterClass(.word, .anyOf("-+.")))
    } transform: {
      String($0)
    }

    let dataReference = Reference(String.self)
    let dataCapture = Capture(as: dataReference) {
      ZeroOrMore(.any)
    } transform: {
      String($0)
    }

    let base64Reference = Reference(String?.self)
    let base64Capture = Capture(as: base64Reference) {
      ";base64"
    } transform: {
      String($0)
    }

    let dataURLRegex = Regex {
      "data:"
      Optionally(mediaTypeCapture)
      Optionally(base64Capture)
      ","
      dataCapture
    }

    guard let match = try? dataURLRegex.wholeMatch(in: absoluteString) else { return nil }
    return DataURLComponents(
      mediaType: match[mediaTypeReference],
      data: match[dataReference],
      isBase64: match[base64Reference] != nil)
  }
}
