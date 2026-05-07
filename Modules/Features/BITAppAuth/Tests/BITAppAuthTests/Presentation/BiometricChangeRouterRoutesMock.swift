import Foundation
@testable import BITAppAuth
@testable import BITNavigation

class BiometricChangeRouterRoutesMock: ClosableRoutesMock, BiometricChangeRouterRoutes {

  var loginCalled = false
  var biometicStatusUpdateCalled = false

  // swiftlint:disable weak_delegate
  var delegate: (any BITAppAuth.BiometricChangeDelegate)?

  // swiftlint:enable weak_delegate

  func login(animated: Bool) {
    loginCalled = true
  }

  func biometricStatusUpdate() {
    biometicStatusUpdateCalled = true
  }
}
