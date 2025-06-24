import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ClientAttestationErrorView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.clientAttestationErrorViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.closeCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestClientAttestationErrorPrimary,
          secondary: L10n.tkEidRequestClientAttestationErrorSecondary,
          tertiary: L10n.tkEidRequestClientAttestationErrorTertiary,
          tertiaryAction: viewModel.openHelp)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestClientAttestationErrorPrimaryButton,
          primaryButtonAction: viewModel.primaryAction,
          secondaryButtonLabel: L10n.tkEidRequestClientAttestationErrorSecondaryButton,
          secondaryButtonAction: viewModel.secondaryAction)
      })
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private var viewModel: ClientAttestationErrorViewModel

}
