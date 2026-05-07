import BITL10n
import BITNavigation
import BITTheming
import Factory
import SwiftUI

// MARK: - SuccessView

struct SuccessView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    self.caseId = caseId
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.timer.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestAgentReviewPrimary),
        .body(L10n.tkEidRequestAgentReviewSecondary),
      ],
      actions: [
        .primary(L10n.tkGlobalClose) { navigator in
          coordinator.cleanup()
          navigator.returnToCheckpointSafely(Checkpoints.home, value: .startRequestCasePolling(caseId: caseId))
        },
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  private let caseId: String

  @Injected(\.eidRequestFlowCoordinator) private var coordinator
}

#if DEBUG
#Preview {
  SuccessView(caseId: "caseId")
}
#endif
