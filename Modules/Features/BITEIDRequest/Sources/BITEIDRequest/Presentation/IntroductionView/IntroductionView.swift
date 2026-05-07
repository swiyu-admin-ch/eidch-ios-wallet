import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct IntroductionView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.card.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestIntroTitle),
        .body(L10n.tkEidRequestIntroBody),
        .caption(L10n.tkEidRequestIntroSmallBody),
      ],
      actions: [
        .primary(L10n.tkEidRequestIntroPrimaryButton, { navigator in
          navigator.navigate(to: EIDRequestDestinations.dataPrivacyView)
        }),
        .secondary(L10n.tkEidRequestIntroSecondaryButton, { navigator in
          navigator.dismiss()
        }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator: Navigator
}

#Preview {
  IntroductionView()
}
