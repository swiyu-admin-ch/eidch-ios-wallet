import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - NFCHelpView

struct NFCHelpView: View {

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(
      primaryContent: {
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
          Assets.nfc.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(minWidth: imageMinWidth, maxWidth: imageMaxWidth, minHeight: imageMinHeight, maxHeight: imageMaxHeight)
        }
        .accessibilityHidden(true)
      },
      secondaryContent: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestNfcScanHelpPrimary,
          secondary: L10n.tkEidRequestNfcScanHelpSecondary)
          .padding(.horizontal, .x6)
          .accessibilityPriorityFocus()
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: {
            navigator.navigate(to: EIDRequestDestinations.nfcHelpFailure)
          })
      })
      .navigationDestination(EIDRequestDestinations.self)
      .navigationTitle(L10n.tkEidRequestNfcScanHelpTitle)
      .navigationBarTitleDisplayMode(.inline)
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let imageMinWidth: CGFloat = 80
  private let imageMaxWidth: CGFloat = 250
  private let imageMinHeight: CGFloat = 80
  private let imageMaxHeight: CGFloat = 250
}

#Preview {
  NFCHelpView()
}
