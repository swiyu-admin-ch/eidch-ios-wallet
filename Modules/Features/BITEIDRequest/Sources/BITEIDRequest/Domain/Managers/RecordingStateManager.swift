import BITCore
import Foundation
import Spyable

// MARK: - RecordingStateProtocol

@Spyable
@MainActor
protocol RecordingStateProtocol {
  var recordingTimeout: TimeInterval { get }
  var delegate: RecordingStateDelegate? { get set }

  func startRecording()
  func stopRecording()
  func startProcessing()
  func finishProcessingSuccessfully()
}

// MARK: - RecordingStateDelegate

@Spyable
@MainActor
protocol RecordingStateDelegate: AnyObject, Vibrating {
  var recordingState: RecordingState { get set }
  func read(announcement: RecordingAnnouncement)
}

// MARK: - RecordingStateManager

@MainActor
final class RecordingStateManager: RecordingStateProtocol {

  // MARK: Lifecycle

  init(recordingTimeout: TimeInterval = 10) {
    self.recordingTimeout = recordingTimeout
  }

  deinit {
    timerTask?.cancel()
  }

  // MARK: Internal

  let recordingTimeout: TimeInterval

  weak var delegate: RecordingStateDelegate?

  func startRecording() {
    reset()
    updateRecordingCountdownState()

    timerTask = Task { [weak self] in
      let publisher = Timer
        .publish(every: 1, on: .main, in: .default)
        .autoconnect()

      for await _ in publisher.values {
        guard !Task.isCancelled else { break }
        self?.incrementCountdown()
      }
    }
  }

  func stopRecording() {
    reset()
    updateState(to: .initial)
  }

  func startProcessing() {
    updateState(to: .loading)
  }

  func finishProcessingSuccessfully() {
    updateState(to: .success)
  }

  // MARK: Private

  private var timerTask: Task<Void, Never>?
  private var elapsedTime: TimeInterval = 0

  private func reset() {
    timerTask?.cancel()
    timerTask = nil
    elapsedTime = 0
  }

  private func incrementCountdown() {
    elapsedTime += 1
    updateRecordingCountdownState()

    guard elapsedTime == recordingTimeout else { return }
    stopRecording()
  }
}

// MARK: - Delegate state updates

extension RecordingStateManager {
  private func updateRecordingCountdownState() {
    let recordingType = RecordingType.countdown(elapsedTime: elapsedTime, timeout: recordingTimeout)
    updateState(to: .recording(type: recordingType))
  }

  private func updateState(to state: RecordingState) {
    guard delegate?.recordingState != state else { return }
    delegate?.recordingState = state

    makeAccessibilityAnnounceIfNeeded(for: state)

    vibrateIfNeeded(for: state)
  }

  private func makeAccessibilityAnnounceIfNeeded(for state: RecordingState) {
    let announcement: RecordingAnnouncement? = switch state {
    case .loading: .processingStarted
    case .success: .processingSucceeded
    case .initial,
         .recording: nil
    }

    guard let announcement else { return }
    delegate?.read(announcement: announcement)
  }

  private func vibrateIfNeeded(for state: RecordingState) {
    guard case .loading = state else { return }
    delegate?.vibrate(.success)
  }
}
