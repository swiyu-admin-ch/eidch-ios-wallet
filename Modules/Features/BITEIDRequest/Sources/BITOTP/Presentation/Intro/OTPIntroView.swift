import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct OTPIntroView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.eid.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestOtpIntroTitle),
        .body(L10n.tkEidRequestOtpIntroBody),
      ],
      actions: actions)
      .navigationBarBackButtonHidden()
      .toolbar {
        CloseButtonToolbar { navigator.dismiss() }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @Injected(\.isOTPSkipEnabled) private var isOTPSkipEnabled

  private var actions: [InformationView2.ActionType] {
    var actions: [InformationView2.ActionType] = [
      .primary(L10n.tkEidRequestOtpIntroPrimaryButton, { navigator in
        navigator.navigate(to: OTPDestinations.legal)
      }),
      .secondary(L10n.tkEidRequestOtpIntroSecondaryButton, { navigator in
        navigator.dismiss()
      }),
    ]

    if isOTPSkipEnabled {
      actions.append(.secondary(L10n.tkEidRequestOtpEmailSkipButton, identifier: "skipButton", { navigator in
        navigator.navigate(to: OTPDestinations.external(.eidRequest))
      }))
    }

    return actions
  }
}

#Preview {
  OTPIntroView()
}
