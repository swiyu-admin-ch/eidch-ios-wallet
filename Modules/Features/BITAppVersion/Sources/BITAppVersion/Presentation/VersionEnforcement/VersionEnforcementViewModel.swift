import BITL10n
import Factory
import Foundation

class VersionEnforcementViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: VersionEnforcementRouterRoutes = Container.shared.versionEnforcementRouter(), versionEnforcement: VersionEnforcement) {
    self.router = router
    self.versionEnforcement = versionEnforcement
  }

  // MARK: Internal

  var title: String {
    guard let display = versionEnforcement.displays.findDisplayWithFallback() as? VersionEnforcement.Display else {
      return "n/a"
    }

    return display.title
  }

  var content: String {
    guard let display = versionEnforcement.displays.findDisplayWithFallback() as? VersionEnforcement.Display else {
      return "n/a"
    }

    return display.body
  }

  func openAppStore() {
    guard let appStoreUrl = URL(string: L10n.versionEnforcementStoreLink) else {
      return
    }

    router.openExternalLink(url: appStoreUrl)
  }

  // MARK: Private

  private let router: VersionEnforcementRouterRoutes
  private let versionEnforcement: VersionEnforcement
}
