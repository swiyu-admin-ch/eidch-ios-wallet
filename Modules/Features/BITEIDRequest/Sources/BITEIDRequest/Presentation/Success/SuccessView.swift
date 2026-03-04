import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - SuccessView

struct SuccessView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.timer.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestAgentReviewPrimary),
        .body(L10n.tkEidRequestAgentReviewSecondary),
      ],
      actions: [
        .primary(
          L10n.tkGlobalClose,
          { _ in
            coordinator.cleanup()
            navigator.dismiss()
          }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @Injected(\.eidRequestFlowCoordinator) private var coordinator
}

#if DEBUG
#Preview {
  SuccessView()
}
#endif
