import BITAppAuth
import BITAppInfo
import Foundation
@testable import BITNavigation

class LoginRouterMock: ClosableRoutesMock, LoginRouterRoutes {

  var didCallLogin = false
  var didCallAppSettings = false
  var didCallversionEnforcement = false

  private(set) var versionEnforcement: VersionEnforcement?

  func login(animated: Bool) {
    didCallLogin = true
  }

  func appSettings() {
    didCallAppSettings = true
  }

  func versionEnforcement(_ versionEnforcement: VersionEnforcement) {
    didCallversionEnforcement = true
    self.versionEnforcement = versionEnforcement
  }

}
