import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

extension ErrorDataset {
  enum ScanDocument {
    static var wrongDocument: ErrorDataset {
      ErrorDataset(
        [
          .title(L10n.tkEidRequestDocumentScanWrongDocumentPrimary),
          .body(L10n.tkEidRequestDocumentScanWrongDocumentSecondary),
        ],
        actions: [
          .primary(
            L10n.tkEidRequestDocumentScanWrongDocumentButton,
            { navigator in
              Task { @MainActor in
                navigator.returnToCheckpointSafely(EIDRequestCheckpoints.scanDocumentInformation)
              }
            }),
        ])
    }
  }
}
