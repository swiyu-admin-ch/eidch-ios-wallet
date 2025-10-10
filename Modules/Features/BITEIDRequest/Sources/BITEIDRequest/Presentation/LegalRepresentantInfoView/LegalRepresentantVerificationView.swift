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
    InformationView(
      image: Assets.idCheck.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestGuardianVerificationPrimary,
          secondary: L10n.tkEidRequestGuardianVerificationSecondary,
          tertiary: L10n.tkEidRequestGuardianVerificationTertiary)
      },
      footer: {
        ButtonSheet {
          AsyncButton(action: viewModel.startVerification) {
            Text(L10n.tkEidRequestGuardianVerificationButtonStart)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.primary)
          .controlSize(.large)
        }
      })
  }

  // MARK: Private

  private var viewModel: LegalRepresentantVerificationViewModel

}

#Preview {
  LegalRepresentantVerificationView(caseId: "caseId")
}
