import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - SetupView

struct SetupView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = State(initialValue: Container.shared.setupViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    LoadingView(
      primary: L10n.tkOnboardingSetupPrimary,
      secondary: L10n.tkOnboardingSetupSecondary)
      .onFirstAppear {
        Task {
          await viewModel.run()
        }
      }
  }

  // MARK: Private

  @State private var viewModel: SetupViewModel
}

#Preview {
  SetupView(router: OnboardingRouter())
}
