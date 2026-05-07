import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import UIKit

extension ErrorDataset {
  enum OTP {

    // MARK: Internal

    @MainActor
    static var unavailable: ErrorDataset {
      ErrorDataset([
        .hero(.image(Assets.waiting.swiftUIImage)),
        .title(L10n.tkEidRequestOtpUnavailableTitle),
        .body(L10n.tkEidRequestOtpUnavailableBody),
        .captionButton(L10n.tkEidRequestOtpUnavailableLinkText) { _ in
          openLink(L10n.tkEidRequestOtpUnavailableLinkValue)
        },
      ], actions: [
        .primary(L10n.tkEidRequestOtpUnavailablePrimaryButton) { navigator in
          navigator.dismiss()
        },
      ])
    }

    @MainActor
    static var tooManyAttempts: ErrorDataset {
      ErrorDataset([
        .hero(.image(ThemingAssets.closeCircle.swiftUIImage)),
        .title(L10n.tkEidRequestOtpTooManyAttemptsTitle),
        .body(L10n.tkEidRequestOtpTooManyAttemptsBodyPrimary),
        .caption(L10n.tkEidRequestOtpTooManyAttemptsBodySecondary),
      ], actions: [
        .primary(L10n.tkGlobalBack) { navigator in
          navigator.returnToCheckpointSafely(OTPCheckpoints.email)
        },
      ])
    }

    // MARK: Private

    private static func openLink(_ link: String) {
      guard let url = URL(string: link) else { return }
      UIApplication.shared.open(url)
    }
  }
}
