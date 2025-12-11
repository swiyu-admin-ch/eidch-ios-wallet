import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LegalRepresentantConsentView

struct LegalRepresentantConsentView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = StateObject(wrappedValue: Container.shared.legalRepresentantConsentViewModel(caseId))
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
      .toolbar { CloseButtonToolbar(action: { navigator.dismiss() }) }
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @StateObject private var viewModel: LegalRepresentantConsentViewModel
  @Environment(\.navigator) private var navigator
}

#Preview {
  LegalRepresentantConsentView(caseId: "caseId")
}
