import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct ValidateAttestationsErrorView: View {

  // MARK: Lifecycle

  init(error: ErrorWrapper, callback: @escaping (Void) -> Void) {
    _viewModel = StateObject(wrappedValue: Container.shared.validateAttestationsErrorViewModel((error, callback)))
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
      .navigationBack(onChangeOf: $viewModel.isNavigationBackTriggered)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigationBarBackButtonHidden(true)
      .toolbar(.visible)
  }

  // MARK: Private

  @StateObject private var viewModel: ValidateAttestationsErrorViewModel

  @ViewBuilder
  private func footer() -> some View {
    if viewModel.isRetryEnabled {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorPrimaryButton,
        primaryButtonAction: viewModel.primaryAction,
        secondaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorSecondaryButton,
        secondaryButtonAction: viewModel.navigationClose)
    } else {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestAttestationUnknownErrorSecondaryButton,
        primaryButtonAction: viewModel.navigationClose)
    }
  }

}
