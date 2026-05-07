import Foundation

// MARK: - ProximitySubmissionError

public enum ProximitySubmissionError: Error, Equatable {
  case disconnected
  case failed(underlyingErrorMessage: String? = nil)
  case unexpectedTermination
}
