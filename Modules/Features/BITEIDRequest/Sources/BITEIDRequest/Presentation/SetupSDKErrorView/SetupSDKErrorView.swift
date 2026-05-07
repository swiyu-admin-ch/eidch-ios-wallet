import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct SetupSDKErrorView: View {

  // MARK: Lifecycle

  init(error: ErrorWrapper, callback: @escaping (Void) -> Void) {
    _viewModel = State(initialValue: Container.shared.setupSDKErrorViewModel((error, callback)))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.face.swiftUIImage,
      contents: [
        .title(viewModel.primaryText, identifier: "primaryText"),
        .body(viewModel.secondaryText, identifier: "secondaryText"),
      ],
      actions: actions)
      .navigationBack(onChangeOf: $viewModel.isNavigationBackTriggered)
      .navigationBarBackButtonHidden()
      .toolbar(.visible)
  }

  // MARK: Private

  @State private var viewModel: SetupSDKErrorViewModel

  @Environment(\.navigator) private var navigator

  @Injected(\.eidRequestFlowCoordinator) private var eidRequestFlowCoordinator

  private var actions: [InformationView2.ActionType] {
    if viewModel.isRetryEnabled {
      [
        .primary(L10n.tkEidRequestAttestationUnknownErrorPrimaryButton, identifier: "primaryButton", { _ in
          viewModel.primaryAction()
        }),
        .secondary(L10n.tkEidRequestAttestationUnknownErrorSecondaryButton, identifier: "secondaryButton", { _ in
          eidRequestFlowCoordinator.cleanup()
          navigator.dismiss()
        }),
      ]
    } else {
      [
        .primary(L10n.tkEidRequestAttestationUnknownErrorSecondaryButton, identifier: "primaryButton", { _ in
          eidRequestFlowCoordinator.cleanup()
          navigator.dismiss()
        }),
      ]
    }
  }

}
