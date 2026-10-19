import BITCore
import BITNavigation
import Factory
import Foundation
import UIKit

// MARK: - ChangePinCodeRouterRoutes

@MainActor
public protocol ChangePinCodeRouterRoutes: ClosableRoutes, LoginRoutes, ChangePinCodeRoutes {}

// MARK: - ChangePinCodeRouter

final public class ChangePinCodeRouter: Router<UIViewController>, ChangePinCodeRoutes, ChangePinCodeInternalRoutes {

  // MARK: Lifecycle

  override init() {
    super.init()
    current = NavigationPushOpeningStyle()
  }

  // MARK: Public

  @Injected(\.changePinCodeContext) public var context: ChangePinCodeContext

}
