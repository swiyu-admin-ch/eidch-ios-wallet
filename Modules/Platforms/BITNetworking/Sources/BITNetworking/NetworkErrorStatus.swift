import Foundation
import Moya

// MARK: - NetworkErrorStatus

public enum NetworkErrorStatus: Error, Equatable, Hashable {

  // >= 400
  case badRequest
  case unauthorized
  case paymentRequired
  case forbidden
  case notFound
  case notAllowed
  case notAcceptable
  case lengthRequired
  case timeout
  case conflict
  case payloadTooLarge
  case uriTooLong
  case unprocessableEntity
  case unsupportedMediaType
  case gone
  case invalidRequest
  case serviceDeactivated

  // >= 500
  case internalServerError
  case notImplemented
  case badGateway
  case serviceUnavailable
  case gatewayTimeout
  case insufficientStorage
  case networkAuthenticationRequired

  // other
  case hostnameNotFound
  case unknown(message: String?)
  case noConnection

  // token
  case invalidUser
  case invalidToken
  case expiredToken

  // custom

  /// 400 when receiving badRequest with "error: invalid_grant" in the body
  case invalidGrant
  case pinning

  // MARK: Lifecycle

  init(response: Response) {
    self.init(httpStatusCode: response.statusCode)
    if self == .badRequest {
      self = NetworkErrorStatus.parseBadRequest(response: response)
    }
  }

  init(httpStatusCode: Int) {
    switch httpStatusCode {
    case 400: self = .badRequest
    case 401: self = .unauthorized
    case 402: self = .paymentRequired
    case 403: self = .forbidden
    case 404: self = .notFound
    case 405: self = .notAllowed
    case 406: self = .notAcceptable
    case 408: self = .timeout
    case 409: self = .conflict
    case 411: self = .lengthRequired
    case 413: self = .payloadTooLarge
    case 414: self = .uriTooLong
    case 415: self = .unsupportedMediaType
    case 418: self = .serviceDeactivated
    case 422: self = .unprocessableEntity
    case 410: self = .gone
    case 500: self = .internalServerError
    case 501: self = .notImplemented
    case 502: self = .badGateway
    case 503: self = .serviceUnavailable
    case 504: self = .gatewayTimeout
    case 507: self = .insufficientStorage
    case 511: self = .networkAuthenticationRequired
    default: self = .unknown(message: nil)
    }
  }

  init(customMessage: String) {
    self = .unknown(message: customMessage)
  }

}

extension NetworkErrorStatus {

  private enum NetworkErrorBodyValue: String {
    case invalidGrant = "INVALID_GRANT"
  }

  private static let errorMap: [String: NetworkErrorStatus] = [
    NetworkErrorBodyValue.invalidGrant.rawValue.uppercased(): .invalidGrant,
  ]

  private static func parseBadRequest(response: Response) -> NetworkErrorStatus {
    guard
      let responseData = try? JSONDecoder().decode([String: String].self, from: response.data),
      let errorValue = responseData["error"]?.uppercased(),
      let networkError = errorMap[errorValue]
    else { return self.init(httpStatusCode: response.statusCode) }

    return networkError
  }

}

// MARK: LocalizedError

extension NetworkErrorStatus: LocalizedError {

  public var errorDescription: String? {
    switch self {
    case .noConnection:
      "No internet connection"

    case .expiredToken,
         .invalidToken,
         .invalidUser,
         .unauthorized:
      "User Auth failed"

    case .badGateway,
         .internalServerError,
         .notImplemented,
         .serviceDeactivated,
         .serviceUnavailable:
      "Server not available"

    case .gatewayTimeout,
         .timeout:
      "Timeout"

    case .hostnameNotFound:
      "Hostname could not be found"

    case .pinning: "Certificate Pinning failure"

    default:
      "Unknown failure..."
    }
  }

  public var errorName: String {
    "\(self)"
  }
}
