import Foundation

// MARK: - NetworkHeader

public enum NetworkHeader {
  case standard
  case authorization(value: String)
  case form
  case swiyuAPIVersion(String)

  // MARK: Private

  // Keys
  private static let keyAccept = "accept"
  private static let keyAuthorization = "authorization"
  private static let keyContentType = "Content-Type"
  private static let swiyuAPIVersion = "SWIYU-API-Version"

  // Values
  private static let valueApplicationJson = "application/json"
  private static let valueApplicationFormUrlEncoded = "application/x-www-form-urlencoded"
}

extension NetworkHeader {
  public var raw: [String: String] {
    switch self {
    case .standard: [
        Self.keyAccept: Self.valueApplicationJson,
      ]
    case .authorization(let value): [
        Self.keyAuthorization: value,
        Self.keyContentType: Self.valueApplicationJson,
      ]
    case .form: [
        Self.keyAccept: Self.valueApplicationJson,
        Self.keyContentType: Self.valueApplicationFormUrlEncoded,
      ]
    case .swiyuAPIVersion(let version): [
        Self.swiyuAPIVersion: version,
      ]
    }
  }
}

extension [NetworkHeader] {
  public var raw: [String: String] {
    Dictionary(uniqueKeysWithValues: flatMap(\.raw))
  }
}
