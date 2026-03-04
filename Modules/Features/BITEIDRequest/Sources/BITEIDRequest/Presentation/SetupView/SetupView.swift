import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - SetupView

struct SetupView: View {

  // MARK: Internal

  var body: some View {
    LoadingView(
      primary: L10n.tkEidRequestAttestationPrimary,
      secondary: L10n.tkEidRequestAttestationSecondary,
      action: LoadingView.Action(
        action: viewModel.cancelInitialization,
        buttonText: L10n.tkGlobalCancel),
      progressViewStyle: .infinite)
      .navigate(to: $viewModel.destination)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .onFirstAppear {
        Task {
          await viewModel.fetchAttestations()
        }
      }
  }

  // MARK: Private

  @InjectedObject(\.setupViewModel) private var viewModel
}

#Preview {
  SetupView()
}
