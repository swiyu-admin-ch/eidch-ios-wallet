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
          primary: L10n.tkGetBetaIdCreateTitle,
          secondary: L10n.tkGetBetaIdCreateBody)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalGetbetaidPrimarybutton,
          primaryButtonAction: openBetaIdLink)
      })
      .toolbar { toolbar }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: { dismiss() }, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
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
