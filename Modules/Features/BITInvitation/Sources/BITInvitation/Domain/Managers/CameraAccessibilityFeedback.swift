import BITL10n
import Spyable
import UIKit

// MARK: - CameraAccessibilityFeedbackProtocol

@Spyable
@MainActor
protocol CameraAccessibilityFeedbackProtocol {
  func announceCameraDidStartRunning()
  func announceCameraDidStopRunning()
  func announceQRCodeDetected()
  func stopQRCodeLoadingAnnouncements()
}

// MARK: - CameraAccessibilityFeedback

@MainActor
final class CameraAccessibilityFeedback: CameraAccessibilityFeedbackProtocol {

  // MARK: Lifecycle

  deinit {
    announcementTimer = nil
  }

  // MARK: Internal

  func announceCameraDidStartRunning() {
    announce(L10n.tkQrscannerCameraFeedAlt)
  }

  func announceCameraDidStopRunning() {
    stopQRCodeLoadingAnnouncements()
    announce(L10n.tkQrscannerCameraOffAlt)
  }

  func announceQRCodeDetected() {
    announce(L10n.tkQrscannerProcessingAlt)
    announcementTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      self?.announce(L10n.tkGlobalPleasewait)
    }
  }

  func stopQRCodeLoadingAnnouncements() {
    announcementTimer = nil
  }

  // MARK: Private

  private var announcementTimer: Timer? {
    willSet { announcementTimer?.invalidate() }
  }

  private func announce(_ string: String) {
    guard UIAccessibility.isVoiceOverRunning else { return }

    var announcementString = AttributedString(string)
    announcementString.accessibilitySpeechAnnouncementPriority = .high
    AccessibilityNotification.Announcement(announcementString).post()
  }
}
