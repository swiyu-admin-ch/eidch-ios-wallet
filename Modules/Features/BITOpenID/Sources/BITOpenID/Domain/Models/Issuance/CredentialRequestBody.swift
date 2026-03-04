import BITNetworking
import Foundation

public enum CredentialRequestBody: Encodable {
  case json(CredentialRequest)
  case jwe(String)

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .json(let request):
      try request.encode(to: encoder)
    case .jwe(let token):
      var container = encoder.singleValueContainer()
      try container.encode(token)
    }
  }

  // MARK: Internal

  var contentType: ContentType {
    switch self {
    case .json: .json
    case .jwe: .jwt
    }
  }
}
