import BITL10n
import BITTheming
import Factory
import SwiftUI

struct KeyAttestationErrorView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.keyAttestationErrorViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.closeCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestKeyAttestationErrorPrimary,
          secondary: L10n.tkEidRequestKeyAttestationErrorSecondary,
          tertiary: L10n.tkEidRequestKeyAttestationErrorTertiary,
          tertiaryAction: viewModel.openHelp)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestKeyAttestationErrorPrimaryButton,
          primaryButtonAction: viewModel.primaryAction)
      })
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private var viewModel: KeyAttestationErrorViewModel

}
