import BITL10n
import Factory
import Foundation

@Observable
class VersionEnforcementViewModel {

  // MARK: Lifecycle

  init(router: VersionEnforcementRouterRoutes = Container.shared.versionEnforcementRouter(), versionEnforcement: VersionEnforcement) {
    self.router = router
    self.versionEnforcement = versionEnforcement
  }

  // MARK: Internal

  var title: String {
    guard let display = versionEnforcement.displays.findDisplayWithFallback() else {
      return "n/a"
    }

    return display.title
  }

  var content: String {
    guard let display = versionEnforcement.displays.findDisplayWithFallback() else {
      return "n/a"
    }

    return display.body
  }

  func openAppStore() {
    guard let appStoreUrl = URL(string: L10n.tkGlobalStoreLink) else {
      return
    }

    router.openExternalLink(url: appStoreUrl)
  }

  // MARK: Private

  private let router: VersionEnforcementRouterRoutes
  private let versionEnforcement: VersionEnforcement
}
