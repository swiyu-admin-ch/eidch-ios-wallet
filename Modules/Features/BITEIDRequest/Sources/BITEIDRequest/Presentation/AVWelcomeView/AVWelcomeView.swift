import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct AVWelcomeView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.hand.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestAutoVerificationWelcomePrimary),
        .body(L10n.tkEidRequestAutoVerificationWelcomeSecondary),
        .spacer(),
        .bodyBold(L10n.tkEidRequestAutoVerificationWelcomeTertiaryTip),
        .caption(L10n.tkEidRequestAutoVerificationWelcomeTertiary),
      ],
      actions: [
        .primary(L10n.tkEidRequestAutoVerificationWelcomeButton, identifier: "primaryButton", { _ in
          viewModel.primaryAction()
        }),
      ])
      .navigate(to: $viewModel.destination)
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case tertiaryTipText
  }

  @InjectedObject(\.avWelcomeViewModel) private var viewModel

}

#Preview {
  AVWelcomeView()
}
