import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LegalRepresentantConsentView

struct LegalRepresentantConsentView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = State(initialValue: Container.shared.legalRepresentantConsentViewModel(caseId))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.check.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestGuardianSelectionPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestGuardianSelectionSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .secondary(L10n.tkEidRequestGuardianSelectionButtonObtainConsent, identifier: "primaryButton", { _ in
          viewModel.obtainConsent()
        }),
        .secondary(L10n.tkEidRequestGuardianSelectionButtonContinueAsGuardian, identifier: "secondaryButton", { _ in
          viewModel.continueAsParent()
        }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @State private var viewModel: LegalRepresentantConsentViewModel
}

#Preview {
  LegalRepresentantConsentView(caseId: "caseId")
}
