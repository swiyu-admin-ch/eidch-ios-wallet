import BITL10n
import BITTheming
import SwiftUI

struct TimeoutView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.timer.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestTimeoutPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestTimeoutSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .primary(L10n.tkEidRequestTimeoutButtonRestart, identifier: "primaryButton", { _ in
          close()
        }),
      ])
      .defaultEidRequestToolbar(onClose: close)
      .navigationBarBackButtonHidden()
  }

  // MARK: Private

  private func close() {}

}
