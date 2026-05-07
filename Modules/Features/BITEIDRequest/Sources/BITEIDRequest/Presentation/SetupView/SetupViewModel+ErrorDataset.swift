import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI

extension ErrorDataset {
  public enum Setup {

    // MARK: Public

    @MainActor
    public static var clientAttestation: ErrorDataset {
      ErrorDataset([
        .title(L10n.tkEidRequestClientAttestationErrorPrimary),
        .body(L10n.tkEidRequestClientAttestationErrorSecondary),
        .captionButton(L10n.tkEidRequestClientAttestationErrorTertiary) { _ in
          openLink(L10n.tkEidRequestClientAttestationErrorHelpLink)
        },
      ], actions: [
        .primary(L10n.tkEidRequestClientAttestationErrorPrimaryButton) { _ in
          openLink(L10n.tkGlobalStoreLink)
        },
        .secondary(L10n.tkEidRequestClientAttestationErrorSecondaryButton) { navigator in
          navigator.dismiss()
        },
      ])
    }

    // MARK: Internal

    @MainActor
    static var keyAttestation: ErrorDataset {
      ErrorDataset([
        .title(L10n.tkEidRequestKeyAttestationErrorPrimary),
        .body(L10n.tkEidRequestKeyAttestationErrorSecondary),
        .caption(L10n.tkEidRequestKeyAttestationErrorTertiary),
      ], actions: [
        .primary(L10n.tkEidRequestKeyAttestationErrorPrimaryButton) { navigator in
          navigator.dismiss()
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
