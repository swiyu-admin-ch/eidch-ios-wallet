import Foundation

// MARK: - ProximitySubmissionEvent

public enum ProximitySubmissionEvent: Equatable {
  case progress(Double?)
  case success
}
