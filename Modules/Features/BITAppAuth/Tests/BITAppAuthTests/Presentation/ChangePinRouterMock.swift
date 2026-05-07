import Foundation
@testable import BITAppAuth
@testable import BITNavigation

// MARK: - ChangePinRouterMock

public class ChangePinRouterMock: ClosableRoutesMock, ChangePinCodeInternalRoutes {

  public var context = ChangePinCodeContext()
  public var isClosed = false

  // Protocol methods
  public private(set) var currentPinCodeCalled = false
  public private(set) var newPinCodeCalled = false
  public private(set) var confirmNewPinCodeCalled = false

  public func currentPinCode() {
    currentPinCodeCalled = true
  }

  public func newPinCode() {
    newPinCodeCalled = true
  }

  public func confirmNewPinCode() {
    confirmNewPinCodeCalled = true
  }
}
