import NavigatorUI
import SwiftUI

// MARK: - HomeDestinations

public enum HomeDestinations: NavigationDestination {
  case home
  case external(HomeExternalDestinations)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .home:
      .push
    case .external(let destination):
      switch destination {
      case .settings:
        .managedSheet
      default:
        .managedCover
      }
    }
  }

  public var body: some View {
    HomeDestinationsView(destination: self)
  }
}
