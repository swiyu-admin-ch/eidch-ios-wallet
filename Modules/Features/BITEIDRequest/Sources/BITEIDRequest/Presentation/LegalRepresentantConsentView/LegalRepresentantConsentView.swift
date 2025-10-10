import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LegalRepresentantConsentView

struct LegalRepresentantConsentView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, caseId: String) {
    viewModel = Container.shared.legalRepresentantConsentViewModel((router, caseId))
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.check.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestGuardianSelectionPrimary,
          secondary: L10n.tkEidRequestGuardianSelectionSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestGuardianSelectionButtonObtainConsent,
          primaryButtonStyle: .secondary,
          primaryButtonAction: viewModel.obtainConsent,
          secondaryButtonLabel: L10n.tkEidRequestGuardianSelectionButtonContinueAsGuardian,
          secondaryButtonAction: viewModel.continueAsParent)
      })
      .navigationBarBackButtonHidden(true)
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: LegalRepresentantConsentViewModel
}

#Preview {
  LegalRepresentantConsentView(router: EIDRequestRouter(), caseId: "caseId")
}
