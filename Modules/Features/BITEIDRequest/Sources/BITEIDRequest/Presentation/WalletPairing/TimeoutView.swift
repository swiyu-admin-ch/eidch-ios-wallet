import BITL10n
import BITTheming
import Factory
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
        primaryButtonAction: close)
    }
    .defaultEidRequestToolbar(onClose: close)
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private func close() {}

}
