import BITL10n
import BITTheming
import Factory
import SwiftUI

struct LegalRepresentantVerificationView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    viewModel = Container.shared.legalRepresentantVerificationViewModel(caseId)
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
        .primaryAsync(L10n.tkEidRequestGuardianVerificationButtonStart, identifier: "primaryButton", { _ in
          await viewModel.startVerification()
        }),
      ])
      .toolbar(.visible)
  }

  // MARK: Private

  private var viewModel: LegalRepresentantVerificationViewModel

}

#Preview {
  LegalRepresentantVerificationView(caseId: "caseId")
}
