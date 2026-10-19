import BITAVWrapper
import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

extension ErrorDataset {
  enum NFC {
    static func critical(_ error: AVBeamError, closeAction: @escaping VoidAction)
      -> ErrorDataset
    {
      ErrorDataset(
        ErrorDataset.avBeamContents(for: error),
        actions: [
          .primary(
            L10n.tkGlobalClose,
            { navigator in
              closeAction()
              navigator.dismiss()
            }),
        ])
    }

    static func retry(_ error: Error, _ retryAction: @escaping NavigatorAction)
      -> ErrorDataset
    {
      ErrorDataset(
        [
          .title(L10n.tkEidRequestNfcScanErrorPrimary),
          .body(L10n.tkEidRequestNfcScanErrorSecondary),
          .captionErrorDescription(error),
        ],
        actions: [
          .primary(L10n.tkEidRequestNfcScanErrorButtonRetry, retryAction),
        ])
    }

    static func retryOrContinue(
      _ error: Error,
      continueAction: @escaping NavigatorAction,
      retryAction: @escaping NavigatorAction)
      -> ErrorDataset
    {
      ErrorDataset(
        [
          .title(L10n.tkEidRequestNfcScanErrorFailedPrimary),
          .body(L10n.tkEidRequestNfcScanErrorFailedSecondary),
          .captionErrorDescription(error),
        ],
        actions: [
          .primary(L10n.tkEidRequestNfcScanErrorFailedButtonContinue, continueAction),
          .secondary(L10n.tkEidRequestNfcScanErrorFailedButtonRetry, retryAction),
        ])
    }
  }
}
