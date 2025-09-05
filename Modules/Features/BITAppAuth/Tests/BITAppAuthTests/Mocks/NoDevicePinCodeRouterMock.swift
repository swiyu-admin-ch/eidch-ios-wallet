import BITAppAuth
@testable import BITNavigationTestCore

class NoDevicePinCodeRouterMock: ClosableRoutesMock, NoDevicePinCodeRouterRoutes {
  var didCallExternalSettings = false

  func externalSettings() {
    didCallExternalSettings = true
  }
}
