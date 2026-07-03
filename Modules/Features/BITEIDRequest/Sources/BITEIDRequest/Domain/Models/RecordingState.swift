import Foundation

// MARK: - RecordingState

enum RecordingState: Equatable {
  case initial
  case recording(type: RecordingType = .default)
  case loading
  case success

  var isRecording: Bool {
    switch self {
    case .recording: true
    case .initial,
         .loading,
         .success: false
    }
  }
}

// MARK: - RecordingType

enum RecordingType: Equatable {
  case countdown(elapsedTime: TimeInterval, timeout: TimeInterval)
  case `default`
}
