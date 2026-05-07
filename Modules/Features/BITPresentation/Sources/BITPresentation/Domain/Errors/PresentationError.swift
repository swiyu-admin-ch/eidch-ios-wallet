import BITOpenID

// MARK: - PresentationError

public enum PresentationError: Error, Equatable, Hashable {
  case submitPresentationError(String?, String?)
  case authorizationRequestError
  case invalidCredential
}

extension PresentationError {
  init?(_ error: Error) {
    if let presentationError = error as? PresentationError {
      self = presentationError
    }

    if let repositoryError = error as? PresentationRequestRepositoryError {
      switch repositoryError {
      case .presentationResponseError(let rawErrorCode, let errorDescription):
        self = PresentationError.submitPresentationError(rawErrorCode, errorDescription)
      case .invalidGrant:
        self = PresentationError.invalidCredential
      }
    } else {
      return nil
    }
  }
}
