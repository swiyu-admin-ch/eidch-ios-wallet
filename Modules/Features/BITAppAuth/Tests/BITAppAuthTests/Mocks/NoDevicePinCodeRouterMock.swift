import BITAppAuth
@testable import BITNavigation

class NoDevicePinCodeRouterMock: ClosableRoutesMock, NoDevicePinCodeRouterRoutes {
  var didCallExternalSettings = false

  func externalSettings() {
    didCallExternalSettings = true
  }
}
