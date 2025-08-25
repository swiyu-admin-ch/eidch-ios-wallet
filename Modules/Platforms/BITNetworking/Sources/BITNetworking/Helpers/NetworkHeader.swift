import Foundation

// MARK: - NetworkHeader

public enum NetworkHeader {
  case standard
  case authorization(String)
  case form

  // MARK: Private

  // Keys
  private static let keyAccept = "accept"
  private static let keyAuthorization = "authorization"
  private static let keyContentType = "Content-Type"

  // Values
  private static let valueBearer = "BEARER"
  private static let valueApplicationJson = "application/json"
  private static let valueApplicationFormUrlEncoded = "application/x-www-form-urlencoded"
}

extension NetworkHeader {
  public var raw: [String: String] {
    switch self {
    case .standard: [
        Self.keyAccept: Self.valueApplicationJson,
      ]
    case .authorization(let token): [
        Self.keyAuthorization: "\(Self.valueBearer) \(token)",
        Self.keyContentType: Self.valueApplicationJson,
      ]
    case .form: [
        Self.keyAccept: Self.valueApplicationJson,
        Self.keyContentType: Self.valueApplicationFormUrlEncoded,
      ]
    }
  }
}
