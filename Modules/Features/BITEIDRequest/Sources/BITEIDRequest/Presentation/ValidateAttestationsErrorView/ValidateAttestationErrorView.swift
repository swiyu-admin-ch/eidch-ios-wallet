import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ValidateAttestationsErrorView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: ValidateAttestationsErrorDelegate, error: Error) {
    viewModel = Container.shared.validateAttestationsErrorViewModel((router, delegate, error))
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.face.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: viewModel.primaryText,
          secondary: viewModel.secondaryText)
      },
      footer: { footer() })
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private var viewModel: ValidateAttestationsErrorViewModel

  @ViewBuilder
  private func footer() -> some View {
    if viewModel.isRetryEnabled {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorPrimaryButton,
        primaryButtonAction: viewModel.primaryAction,
        secondaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorSecondaryButton,
        secondaryButtonAction: viewModel.secondaryAction)
    } else {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorSecondaryButton,
        primaryButtonAction: viewModel.secondaryAction)
    }
  }

}
