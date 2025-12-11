import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LegalRepresentantView

struct LegalRepresentantView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.person.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestGuardianshipPrimary,
          secondary: L10n.tkEidRequestGuardianshipSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestGuardianshipButtonYes,
          primaryButtonStyle: .secondary,
          primaryButtonAction: { viewModel.action(true) },
          secondaryButtonLabel: L10n.tkEidRequestGuardianshipButtonNo,
          secondaryButtonAction: { viewModel.action(false) })
      })
      .navigationBarBackButtonHidden()
      .toolbar { CloseButtonToolbar(action: { navigator.dismiss() }) }
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @InjectedObject(\.legalRepresentantViewModel) private var viewModel
  @Environment(\.navigator) private var navigator
}

#Preview {
  LegalRepresentantView()
}
