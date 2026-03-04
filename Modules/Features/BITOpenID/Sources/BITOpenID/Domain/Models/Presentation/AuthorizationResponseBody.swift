import Foundation

// MARK: - DictionarySerializable

public protocol DictionarySerializable {
  func asDictionary() -> [String: Any]
}

// MARK: - AuthorizationResponseBody

public enum AuthorizationResponseBody: DictionarySerializable {
  case json(DictionarySerializable, AuthorizationResponseType)
  case jwe(String, AuthorizationResponseType)

  public func asDictionary() -> [String: Any] {
    switch self {
    case .json(let payload, _):
      payload.asDictionary()
    case .jwe(let token, _):
      ["response": token]
    }
  }

  public var type: AuthorizationResponseType {
    switch self {
    case .json(_, let type): type
    case .jwe(_, let type): type
    }
  }
}
