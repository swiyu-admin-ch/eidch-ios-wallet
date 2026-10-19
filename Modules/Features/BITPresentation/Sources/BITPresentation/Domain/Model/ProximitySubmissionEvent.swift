import Foundation

// MARK: - ProximitySubmissionEvent

public enum ProximitySubmissionEvent: Equatable, Sendable {
  case progress(Double?)
  case success
}
