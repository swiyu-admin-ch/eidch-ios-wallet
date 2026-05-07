import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct AVIdentityCheckView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = State(initialValue: Container.shared.avIdentityCheckViewModel(caseId))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.idCheck.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestAutoVerificationIdentityCheckPrimary, identifier: AccessibilityIdentifier.primaryText.rawValue),
        .body(L10n.tkEidRequestAutoVerificationIdentityCheckSecondary, identifier: AccessibilityIdentifier.secondaryText.rawValue),
        .spacer(),
        .bodyBold(L10n.tkEidRequestAutoVerificationIdentityCheckTertiaryTip, identifier: AccessibilityIdentifier.tertiaryTipText.rawValue),
        .caption(L10n.tkEidRequestAutoVerificationIdentityCheckTertiary, identifier: AccessibilityIdentifier.tertiaryText.rawValue),
      ],
      actions: [
        .primaryAsync(L10n.tkEidRequestAutoVerificationIdentityCheckButton, actionOptions: [.showProgressView], { _ in
          await viewModel.primaryAction()
        }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case tertiaryTipText
  }

  @State private var viewModel: AVIdentityCheckViewModel
}

#Preview {
  AVIdentityCheckView(caseId: "caseId")
}
