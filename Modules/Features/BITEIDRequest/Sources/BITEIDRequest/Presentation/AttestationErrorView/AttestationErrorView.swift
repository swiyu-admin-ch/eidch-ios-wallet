import BITL10n
import BITTheming
import Factory
import SwiftUI

struct AttestationErrorView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: AttestationErrorDelegate) {
    viewModel = Container.shared.attestationErrorViewModel((router, delegate))
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.face.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestAttestationUnknownErrorPrimary,
          secondary: L10n.tkEidRequestAttestationUnknownErrorSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorPrimaryButton,
          primaryButtonAction: viewModel.primaryAction,
          secondaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorSecondaryButton,
          secondaryButtonAction: viewModel.secondaryAction)
      })
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private var viewModel: AttestationErrorViewModel

}
