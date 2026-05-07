import BITL10n
import BITTheming
import SwiftUI

// MARK: - NFCHelpView

struct ScanDocumentInformationView: View {

  // MARK: Lifecycle

  init(isBackEnabled: Bool = false) {
    self.isBackEnabled = isBackEnabled
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.scanDocumentPreview.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestScanDocumentInformationPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestScanDocumentInformationSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .primary(L10n.tkEidRequestScanDocumentInformationButtonPrimary, identifier: "primaryButton", { navigator in
          navigator.navigate(to: EIDRequestDestinations.scanDocument)
        }),
      ])
      .navigationDestination(EIDRequestDestinations.self)
      .navigationCheckpoint(EIDRequestCheckpoints.scanDocumentInformation)
      .navigationBarTitleDisplayMode(.inline)
      .defaultEidRequestToolbar()
      .navigationBarBackButtonHidden(!isBackEnabled)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private var isBackEnabled: Bool

}

#Preview {
  ScanDocumentInformationView()
}
