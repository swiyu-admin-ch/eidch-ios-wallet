import Foundation

public enum ContentType: String {
  case json = "application/json"
  case jwt = "application/jwt"

  public init(_ response: HTTPURLResponse?) {
    guard let header = response?.value(forHTTPHeaderField: "Content-Type") else {
      self = .json
      return
    }

    self = header.lowercased().contains(Self.jwt.rawValue) ? .jwt : .json
  }
}
