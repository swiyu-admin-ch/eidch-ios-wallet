import Factory
import NavigatorUI

@MainActor
extension Container {

  var homeViewModel: Factory<HomeViewModel> {
    self { @MainActor in HomeViewModel() }
  }
}

extension Container {
  public var isBetaIdEnabled: Factory<Bool> {
    self { true }
  }

  public var homeExternalViewProvider: Factory<(any NavigationViewProviding<HomeExternalDestinations>)?> {
    self { @MainActor in nil }
  }
}
