import BITL10n
import BITTheming
import SwiftUI

struct BetaIdView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.betaId.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.getBetaIdTitle,
          secondary: L10n.getBetaIdBody)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.getBetaIdButton,
          primaryButtonAction: openBetaIdLink)
      })
      .toolbar { toolbar }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    CloseButtonToolbar(action: { dismiss() })
  }

  private func openBetaIdLink() {
    if let url = URL(string: L10n.tkGlobalBetaidUrl) {
      UIApplication.shared.open(url)
    }
  }

}

#Preview {
  BetaIdView()
}
