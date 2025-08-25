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
          primary: L10n.tkGetEidGuardianshipPrimary,
          secondary: L10n.tkGetEidGuardianshipSecondary)
      },
      footer: {
        viewFooter()
      })
      .navigationBarBackButtonHidden()
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case yesButton
    case noButton
  }

  private var viewModel: LegalRepresentantViewModel
}

extension LegalRepresentantView {

  @ViewBuilder
  private func viewFooter() -> some View {
    Button(action: { viewModel.action(true) }) {
      Text(L10n.tkGetEidGuardianshipButtonYes)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.yesButton.rawValue)

    Button(action: { viewModel.action(false) }) {
      Text(L10n.tkGetEidGuardianshipButtonNo)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.noButton.rawValue)
  }
}

#Preview {
  LegalRepresentantView(router: EIDRequestRouter())
}
