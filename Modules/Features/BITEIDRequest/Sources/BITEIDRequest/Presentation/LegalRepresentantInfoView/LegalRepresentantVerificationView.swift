import BITL10n
import BITNavigation
import BITPresentation
import BITTheming
import Factory
import SwiftUI

struct LegalRepresentantVerificationView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = StateObject(wrappedValue: Container.shared.legalRepresentantVerificationViewModel(caseId))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.idCheck.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestGuardianVerificationPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestGuardianVerificationSecondary, identifier: "secondaryText"),
        .caption(L10n.tkEidRequestGuardianVerificationTertiary, identifier: "tertiaryText"),
      ],
      actions: [
        .primaryAsync(L10n.tkEidRequestGuardianVerificationButtonStart, identifier: "primaryButton") { _ in
          await viewModel.startVerification()
        },
      ])
      .toolbar(.visible)
      .navigate(to: $viewModel.destination)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigationCheckpoint(PresentationCheckpoints.didFinish) { state in
        Task {
          await viewModel.finish(with: state)
        }
      }
  }

  // MARK: Private

  @StateObject private var viewModel: LegalRepresentantVerificationViewModel
}

#Preview {
  LegalRepresentantVerificationView(caseId: "caseId")
}
