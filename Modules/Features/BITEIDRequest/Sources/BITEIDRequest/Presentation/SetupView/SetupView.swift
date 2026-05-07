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
        action: { viewModel.cancelInitialization(navigator) },
        buttonText: L10n.tkGlobalCancel),
      progressViewStyle: .infinite)
      .navigate(to: $viewModel.destination)
      .onFirstAppear {
        Task {
          await viewModel.fetchAttestations()
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @InjectedObservable(\.setupViewModel) private var viewModel: SetupViewModel
}

#Preview {
  SetupView()
}
