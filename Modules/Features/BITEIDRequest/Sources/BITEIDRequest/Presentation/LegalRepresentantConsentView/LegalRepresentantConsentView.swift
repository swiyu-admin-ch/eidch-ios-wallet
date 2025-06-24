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
          primary: L10n.tkGetEidGuardianSelectionPrimary,
          secondary: L10n.tkGetEidGuardianSelectionSecondary)
      },
      footer: {
        viewFooter()
      })
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case obtainConsentButton
    case continueButton
  }

  private var viewModel: LegalRepresentantConsentViewModel
}

extension LegalRepresentantConsentView {

  @ViewBuilder
  private func viewFooter() -> some View {
    Button(action: viewModel.obtainConsent) {
      Text(L10n.tkGetEidGuardianSelectionButtonObtainConsent)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.obtainConsentButton.rawValue)

    Button(action: viewModel.continueAsParent) {
      Text(L10n.tkGetEidGuardianSelectionButtonContinueAsGuardian)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.continueButton.rawValue)
  }
}

#Preview {
  LegalRepresentantConsentView(router: EIDRequestRouter(), caseId: "caseId")
}
