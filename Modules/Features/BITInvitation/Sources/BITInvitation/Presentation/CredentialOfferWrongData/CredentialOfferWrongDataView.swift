import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialOfferWrongDataView

struct CredentialOfferWrongDataView: View {

  // MARK: Lifecycle

  init(router: CredentialOfferInternalRoutes) {
    viewModel = Container.shared.credentialOfferWrongDataViewModel(router)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialOfferWrongDataContent"
    case closeButton
  }

  var body: some View {
    InformationView(
      image: Assets.xmarkCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.system.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkReceiveCredentialOfferWrongDataPrimary,
          secondary: L10n.tkReceiveCredentialOfferWrongDataSecondary)
      })
      .toolbar(content: toolbarContent)
      .ignoresSafeArea(edges: .bottom)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private var viewModel: CredentialOfferWrongDataViewModel

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: viewModel.close, label: {
        Assets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
    }
  }
}

#if DEBUG
#Preview {
  CredentialOfferWrongDataView(router: CredentialOfferRouter())
}
#endif
