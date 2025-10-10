import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LegalRepresentantView

struct LegalRepresentantView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.legalRepresentantViewModel(router)
  }

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
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: LegalRepresentantViewModel
}

#Preview {
  LegalRepresentantView(router: EIDRequestRouter())
}
