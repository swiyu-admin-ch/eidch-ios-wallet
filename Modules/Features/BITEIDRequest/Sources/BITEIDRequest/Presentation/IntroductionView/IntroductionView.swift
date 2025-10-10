import BITL10n
import BITTheming
import Factory
import SwiftUI

struct IntroductionView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.introductionViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.card.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestIntroTitle,
          secondary: L10n.tkEidRequestIntroBody,
          tertiary: L10n.tkEidRequestIntroSmallBody)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestIntroPrimaryButton,
          primaryButtonAction: viewModel.openDataPrivacy,
          secondaryButtonLabel: L10n.tkEidRequestIntroSecondaryButton,
          secondaryButtonAction: viewModel.close)
      })
  }

  // MARK: Private

  private var viewModel: IntroductionViewModel

}

#Preview {
  IntroductionView(router: EIDRequestRouter())
}
