import Foundation

// MARK: - PresentationRequestError

public enum PresentationRequestError: Error, Equatable {
  case invalidRequestUrl
  case expired
  case presentationRequestNotFound
  case invalid(responseURL: URL?, responseError: PresentationErrorRequestBody.Code)
  case transactionDataNotSupported(responseURL: URL?, responseError: PresentationErrorRequestBody.Code)
}

extension PresentationRequestError {

  public init(validationError error: Error, responseURL: URL?) {
    switch error {
    case RequestObjectValidationError.transactionDataNotSupported:
      self = .transactionDataNotSupported(responseURL: responseURL, responseError: .invalidRequest)
    default:
      self = .invalid(responseURL: responseURL, responseError: .invalidRequest)
    }
  }
}
