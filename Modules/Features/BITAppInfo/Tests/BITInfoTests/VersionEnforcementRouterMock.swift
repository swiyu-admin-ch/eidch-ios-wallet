import BITAppInfo
import Foundation

class VersionEnforcementRouterMock: VersionEnforcementRouterRoutes {

  var closeWithCompletionCalled = false
  var closeCalled = false
  var popCalled = false
  var popCountCalled = false
  var popCountCalledValue = 0
  var popToRootCalled = false
  var dismissCalled = false

  var didCallVersionEnforcement = false
  var didCallExternalLink = false

  func close(onComplete: (() -> Void)?) {
    closeWithCompletionCalled = true
    onComplete?()
  }

  func close() {
    closeCalled = true
  }

  func pop() {
    popCalled = true
  }

  func pop(count: Int) {
    popCountCalledValue = count
    popCountCalled = true
  }

  func popToRoot() {
    popToRootCalled = true
  }

  func dismiss() {
    dismissCalled = true
  }

  func versionEnforcement(_ versionEnforcement: VersionEnforcement) {
    didCallVersionEnforcement = true
  }

  func openExternalLink(url: URL) {
    didCallExternalLink = true
  }
}
