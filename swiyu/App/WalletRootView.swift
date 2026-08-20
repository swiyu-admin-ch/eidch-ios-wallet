import BITHome
import NavigatorUI
import SwiftUI

// MARK: - WalletRootView

struct WalletRootView: View {

  // MARK: Internal

  let coordinator: AppCoordinator
  let navigator: Navigator

  var body: some View {
    ManagedNavigationStack {
      HomeDestinations.home
        .navigationAutoReceive(HomeDestinations.self)
        .onAppear {
          coordinator.handle(.homeDidAppear)
        }
    }
    .navigationRoot(navigator)
    .onChange(of: coordinator.pendingDeeplinkURL, initial: true) { _, url in
      guard let url else { return }
      navigatePendingDeeplink(url)
    }
  }

  // MARK: Private

  private func navigatePendingDeeplink(_ url: URL) {
    navigator.send(values: [
      NavigationAction.reset,
      HomeDestinations.external(.deeplink(url)),
    ])
    coordinator.handle(.pendingDeeplinkNavigated(url))
  }
}
