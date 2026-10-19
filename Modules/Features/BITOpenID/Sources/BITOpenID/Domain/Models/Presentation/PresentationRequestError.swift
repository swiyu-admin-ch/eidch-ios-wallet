import Foundation

// MARK: - PresentationRequestError

public enum PresentationRequestError: Error, Equatable {
  case invalidRequestUrl
  case expired
  case presentationRequestNotFound
  case invalid(responseURL: URL?, state: String?, responseError: PresentationErrorRequestBody.Code)
  case transactionDataNotSupported(responseURL: URL?, state: String?, responseError: PresentationErrorRequestBody.Code)
  case unknownRegistry(responseURL: URL?, state: String?, responseError: PresentationErrorRequestBody.Code)
  case noInternetConnection
}

extension PresentationRequestError {

  public init(validationError error: Error, responseURL: URL?, state: String?) {
    switch error {
    case RequestObjectValidationError.transactionDataNotSupported:
      self = .transactionDataNotSupported(responseURL: responseURL, state: state, responseError: .invalidRequest)
    case RequestObjectValidationError.unknownRegistry:
      self = .unknownRegistry(responseURL: responseURL, state: state, responseError: .invalidRequest)
    default:
      self = .invalid(responseURL: responseURL, state: state, responseError: .invalidRequest)
    }
  }
}
