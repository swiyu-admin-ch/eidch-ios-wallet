import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct AVWelcomeView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    context.caseId = caseId
  }

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
        .primary(L10n.tkEidRequestAutoVerificationWelcomeButton, identifier: "primaryButton") { navigator in
          navigator.push(EIDRequestDestinations.walletPairing)
        },
      ])
      .defaultEidRequestToolbar()
      .navigationCheckpoint(EIDRequestCheckpoints.start)
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
}

#Preview {
  AVWelcomeView(caseId: "caseId")
}
