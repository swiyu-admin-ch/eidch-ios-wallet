import Foundation
import Testing
@testable import BITEIDRequest

@MainActor
@Suite
struct RecordingStateManagerTests {

  // MARK: Lifecycle

  init() {
    let timeout: TimeInterval = 2

    let delegate = RecordingStateDelegateSpy()
    delegate.recordingState = .initial

    let manager = RecordingStateManager(recordingTimeout: timeout)
    manager.delegate = delegate

    self.timeout = timeout
    self.manager = manager
    self.delegate = delegate
  }

  // MARK: Internal

  @Test
  func startRecording() {
    manager.startRecording()

    #expect(delegate.recordingState == .recording(type: .countdown(elapsedTime: 0, timeout: timeout)))
  }

  @Test
  func automaticStopWhenTimeoutIsReached() async throws {
    manager.startRecording()

    try await Task.sleep(seconds: timeout + timerScheduleMargin)

    #expect(delegate.recordingState == .initial)
  }

  @Test
  func stopRecording() {
    manager.stopRecording()

    #expect(delegate.recordingState == .initial)
  }

  @Test
  func startProcessing() {
    manager.startProcessing()

    #expect(delegate.recordingState == .loading)
    #expect(delegate.readAnnouncementReceivedAnnouncement == .processingStarted)
  }

  @Test
  func finishProcessingSuccessfully() {
    manager.finishProcessingSuccessfully()

    #expect(delegate.recordingState == .success)
    #expect(delegate.readAnnouncementReceivedAnnouncement == .processingSucceeded)
  }

  // MARK: Private

  private let manager: RecordingStateManager
  private let timeout: TimeInterval
  private let delegate: RecordingStateDelegateSpy

  private let timerScheduleMargin: TimeInterval = 0.5
}
