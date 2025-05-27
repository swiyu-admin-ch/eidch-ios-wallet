import Foundation

// MARK: - NetworkHeader

public enum NetworkHeader {
  case standard
  case authorization(String)
  case form
  case statusList
  case did
  case vcSchema

  // MARK: Private

  // Keys
  private static let keyAccept = "accept"
  private static let keyAuthorization = "authorization"
  private static let keyContentType = "Content-Type"

  // Values
  private static let valueBearer = "BEARER"
  private static let valueApplicationJson = "application/json"
  private static let valueApplicationJsonLines = "application/jsonl+json"
  private static let valueApplicationFormUrlEncoded = "application/x-www-form-urlencoded"
  private static let valueApplicationStatusList = "application/statuslist+jwt"
  private static let valueApplicationVcSchema = "application/schema+json"
  private static let valueApplicationVcSchemaInstance = "application/schema-instance+json"
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
    case .statusList: [
        Self.keyAccept: Self.valueApplicationStatusList,
      ]
    case .did: [
        Self.keyContentType: Self.valueApplicationJsonLines,
      ]
    case .vcSchema: [
        Self.keyAccept: [Self.valueApplicationJson, Self.valueApplicationVcSchema, Self.valueApplicationVcSchemaInstance].joined(separator: ", "),
      ]
    }
  }
}
