import BITJWT
import Foundation

public enum PresentationRequest: Equatable {
  case plain(RequestObject)
  case jwt(RequestObjectJWS)

  public var requestObject: RequestObject {
    switch self {
    case .plain(let requestObject):
      requestObject
    case .jwt(let jwtRequestObject):
      jwtRequestObject.payload
    }
  }
}
