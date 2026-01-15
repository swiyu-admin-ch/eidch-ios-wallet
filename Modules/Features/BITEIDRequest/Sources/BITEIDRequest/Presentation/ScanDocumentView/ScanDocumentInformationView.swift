import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - NFCHelpView

struct ScanDocumentInformationView: View {

  // MARK: Internal

  var body: some View {
    InformationView(image: Assets.scanDocument.swiftUIImage, backgroundColor: ThemingAssets.Background.secondary.swiftUIColor, content: {
      DefaultInformationContentView(primary: L10n.tkEidRequestScanDocumentInformationPrimary, secondary: L10n.tkEidRequestScanDocumentInformationSecondary)
    }, footer: {
      DefaultInformationFooterView(primaryButtonLabel: L10n.tkEidRequestScanDocumentInformationButtonPrimary) {
        navigator.navigate(to: EIDRequestDestinations.scanDocument)
      }
    })
    .navigationDestination(EIDRequestDestinations.self)
    .navigationCheckpoint(EIDRequestCheckpoints.scanDocumentInformation)
    .navigationBarTitleDisplayMode(.inline)
    .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
}

#Preview {
  ScanDocumentInformationView()
}
