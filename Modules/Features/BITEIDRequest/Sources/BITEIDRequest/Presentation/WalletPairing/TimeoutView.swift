import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI

struct TimeoutView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.timer.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor)
    {
      DefaultInformationContentView(
        primary: L10n.tkEidRequestTimeoutPrimary,
        secondary: L10n.tkEidRequestTimeoutSecondary)
    } footer: {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestTimeoutButtonRestart,
        primaryButtonAction: {
          navigator.dismiss()
        })
    }
    .toolbar { CloseButtonToolbar(action: { navigator.dismiss() }) }
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

}
