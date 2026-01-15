import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - NFCHelpView

struct RecordDocumentInformationView: View {

  // MARK: Internal

  var body: some View {
    InformationView(image: Assets.scanDocument.swiftUIImage, backgroundColor: ThemingAssets.Background.secondary.swiftUIColor, content: {
      DefaultInformationContentView(primary: L10n.tkEidRequestRecordDocumentInformationPrimary, secondary: L10n.tkEidRequestRecordDocumentInformationSecondary)
    }, footer: {
      DefaultInformationFooterView(primaryButtonLabel: L10n.tkEidRequestRecordDocumentInformationButtonPrimary) {
        navigator.navigate(to: EIDRequestDestinations.recordDocument)
      }
    })
    .navigationDestination(EIDRequestDestinations.self)
    .navigationBarTitleDisplayMode(.inline)
    .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
}

#Preview {
  RecordDocumentInformationView()
}
