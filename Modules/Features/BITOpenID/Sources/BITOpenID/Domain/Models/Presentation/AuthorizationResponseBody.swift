import Foundation

// MARK: - DictionarySerializable

public protocol DictionarySerializable {
  func asDictionary() -> [String: Any]
}

// MARK: - AuthorizationResponseBody

public enum AuthorizationResponseBody: DictionarySerializable {
  case json(DictionarySerializable)
  case jwe(String)

  public func asDictionary() -> [String: Any] {
    switch self {
    case .json(let payload):
      payload.asDictionary()
    case .jwe(let token):
      ["response": token]
    }
  }
}
