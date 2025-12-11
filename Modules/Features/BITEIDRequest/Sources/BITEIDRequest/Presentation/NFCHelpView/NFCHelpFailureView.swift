import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - NFCHelpView

struct NFCHelpFailureView: View {

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(
      primaryContent: {
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
          Assets.nfcFailure.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(minWidth: imageMinWidth, maxWidth: imageMaxWidth, minHeight: imageMinHeight, maxHeight: imageMaxHeight)
        }
        .accessibilityHidden(true)
      },
      secondaryContent: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestNfcScanHelpFailurePrimary,
          secondary: L10n.tkEidRequestNfcScanHelpFailureSecondary)
          .padding(.horizontal, .x6)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalClose,
          primaryButtonAction: {
            navigator.dismiss()
          })
      })
      .navigationTitle(L10n.tkEidRequestNfcScanHelpFailureTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        CloseButtonToolbar {
          navigator.dismiss()
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let imageMinWidth: CGFloat = 80
  private let imageMaxWidth: CGFloat = 250
  private let imageMinHeight: CGFloat = 80
  private let imageMaxHeight: CGFloat = 250

}

#Preview {
  NFCHelpFailureView()
}
