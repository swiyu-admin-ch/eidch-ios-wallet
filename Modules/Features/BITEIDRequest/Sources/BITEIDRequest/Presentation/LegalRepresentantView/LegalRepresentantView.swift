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
      .toolbar { toolbarContent() }
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
    Button(action: viewModel.yesAction) {
      Text(L10n.tkGetEidGuardianshipButtonYes)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.yesButton.rawValue)
    .accessibilityLabel(L10n.tkGetEidGuardianshipButtonYes)

    Button(action: viewModel.noAction) {
      Text(L10n.tkGetEidGuardianshipButtonNo)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bezeledLight)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.noButton.rawValue)
    .accessibilityLabel(L10n.tkGetEidGuardianshipButtonNo)
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: viewModel.close, label: {
        Assets.close.swiftUIImage
      })
    }
  }
}

#Preview {
  LegalRepresentantView(router: EIDRequestRouter())
}
