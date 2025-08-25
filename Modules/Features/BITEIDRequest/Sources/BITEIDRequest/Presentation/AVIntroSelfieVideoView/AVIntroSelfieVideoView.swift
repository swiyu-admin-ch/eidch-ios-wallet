import BITL10n
import BITTheming
import Factory
import SwiftUI

struct AVIntroSelfieVideoView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.avIntroSelfieVideoViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.selfie.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestAutoVerificationIntroSelfieVideoPrimary,
          secondary: L10n.tkEidRequestAutoVerificationIntroSelfieVideoSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: viewModel.primaryAction)
      })
      .navigationBarBackButtonHidden(true)
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: AVIntroSelfieVideoViewModel

}

#Preview {
  AVIntroSelfieVideoView(router: EIDRequestRouter())
}
