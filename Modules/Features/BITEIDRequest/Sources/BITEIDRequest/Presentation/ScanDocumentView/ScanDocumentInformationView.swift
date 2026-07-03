import BITL10n
import BITTheming
import Factory
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
      lottie: lottie,
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

  @ObservationIgnored @Injected(\.eidRequestContext) private var context

  private var isBackEnabled: Bool

  private var lottie: LottieView {
    guard case .passport = context.identityType else {
      return Lotties.scanDocFront
    }
    return Lotties.scanDocPass1
  }

}

#Preview {
  ScanDocumentInformationView()
}
