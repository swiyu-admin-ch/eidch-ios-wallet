import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialWrongDataView

struct CredentialDetailWrongDataView: View {

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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        CloseButtonToolbar(accessibilityIdentifier: AccessibilityIdentifier.closeButton.rawValue) {
          navigator.dismiss()
        }
      }
      .ignoresSafeArea(edges: .bottom)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
}
