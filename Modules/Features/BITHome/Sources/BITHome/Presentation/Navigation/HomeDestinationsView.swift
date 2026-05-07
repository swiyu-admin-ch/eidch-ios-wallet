import Factory
import SwiftUI

struct HomeDestinationsView: View {

  // MARK: Lifecycle

  init(destination: HomeDestinations) {
    self.destination = destination
  }

  // MARK: Internal

  var body: some View {
    switch destination {
    case .home:
      HomeView()
    case .external(let externalDestination):
      homeExternalViewProvider?.view(for: externalDestination)
    }
  }

  // MARK: Private

  private let destination: HomeDestinations
  @Injected(\.homeExternalViewProvider) private var homeExternalViewProvider
}
