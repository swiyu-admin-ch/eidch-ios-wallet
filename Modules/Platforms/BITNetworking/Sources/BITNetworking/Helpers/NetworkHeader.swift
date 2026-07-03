import Foundation

// MARK: - NetworkHeader

public enum NetworkHeader {
  case standard
  case authorization(value: String)
  case dpop(String)
  case form
  case swiyuAPIVersion(String)
  case contentType(String)
  case accept(String)
  case acceptLanguage([String])
  case formUrlEncoded

  // MARK: Private

  // Keys
  private static let keyAccept = "accept"
  private static let keyAcceptLanguage = "Accept-Language"
  private static let keyAuthorization = "authorization"
  private static let keyContentType = "Content-Type"
  private static let keyDPoP = "DPoP"
  private static let swiyuAPIVersion = "SWIYU-API-Version"

  // Values
  private static let valueApplicationJson = "application/json"
  private static let valueApplicationFormUrlEncoded = "application/x-www-form-urlencoded"
}

extension NetworkHeader {
  public static let swiyuUserAgent = "swiyu"

  public var raw: [String: String] {
    switch self {
    case .standard: [
        Self.keyAccept: Self.valueApplicationJson,
      ]
    case .authorization(let value): [
        Self.keyAuthorization: value,
        Self.keyContentType: Self.valueApplicationJson,
      ]
    case .dpop(let value): [
        Self.keyDPoP: value,
      ]
    case .form: [
        Self.keyAccept: Self.valueApplicationJson,
        Self.keyContentType: Self.valueApplicationFormUrlEncoded,
      ]
    case .swiyuAPIVersion(let version): [
        Self.swiyuAPIVersion: version,
      ]
    case .contentType(let value): [
        Self.keyContentType: value,
      ]
    case .accept(let value): [
        Self.keyAccept: value,
      ]
    case .acceptLanguage(let value): [
        Self.keyAcceptLanguage: value.joined(separator: ", "),
      ]
    case .formUrlEncoded: [
        Self.keyContentType: Self.valueApplicationFormUrlEncoded,
      ]
    }
  }
}

extension [NetworkHeader] {
  public var raw: [String: String] {
    reduce(into: [:]) { dict, header in
      for (key, value) in header.raw {
        dict[key] = value
      }
    }
  }
}
