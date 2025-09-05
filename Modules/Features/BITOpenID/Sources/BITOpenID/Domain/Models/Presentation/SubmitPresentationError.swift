import Foundation

// MARK: - SubmitPresentationError

public enum SubmitPresentationError: Error {
  case presentationFailed
  case processClosed
  case invalidCredential
  case wrongSubmissionUrl
}
