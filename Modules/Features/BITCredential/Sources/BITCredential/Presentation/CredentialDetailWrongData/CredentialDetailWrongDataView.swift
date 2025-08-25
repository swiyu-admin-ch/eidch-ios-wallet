import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialWrongDataView

struct CredentialDetailWrongDataView: View {

  // MARK: Lifecycle

  init(router: CredentialDetailInternalRoutes) {
    viewModel = Container.shared.credentiaDetaillWrongDataViewModel(router)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialDetailWrongDataContent"
    case closeButton = "credentialDetailWrongDataCloseButton"
  }

  var body: some View {
    InformationView(
      image: Assets.xmarkCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.system.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkDisplaydeleteWrongdataTitle,
          secondary: L10n.tkDisplaydeleteWrongdataBody)
      })
      .navigationTitle(L10n.tkDisplaydeleteWrongdataNavigationTitle)
      .toolbar(content: toolbarContent)
      .ignoresSafeArea(edges: .bottom)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private var viewModel: CredentialDetailWrongDataViewModel

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button(action: viewModel.close, label: {
        Assets.closeAlt.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
    }
  }
}
