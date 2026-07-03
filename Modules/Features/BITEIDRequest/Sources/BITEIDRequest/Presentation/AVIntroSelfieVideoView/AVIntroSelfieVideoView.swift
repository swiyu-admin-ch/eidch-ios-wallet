import BITL10n
import BITTheming
import SwiftUI

struct AVIntroSelfieVideoView: View {

  var body: some View {
    InformationView2(
      lottie: Lotties.confirmIdentity,
      contents: [
        .title(L10n.tkEidRequestAutoVerificationIntroSelfieVideoPrimary),
        .body(L10n.tkEidRequestAutoVerificationIntroSelfieVideoSecondary),
      ],
      actions: [
        .primary(L10n.tkGlobalContinue, { navigator in
          navigator.navigate(to: EIDRequestDestinations.recordSelfie)
        }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
      .navigationCheckpoint(EIDRequestCheckpoints.recordSelfieInformation)
  }

  // MARK: Private

}

#Preview {
  AVIntroSelfieVideoView()
}
