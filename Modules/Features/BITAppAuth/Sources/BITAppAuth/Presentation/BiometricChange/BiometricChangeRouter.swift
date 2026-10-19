import BITCore
import BITNavigation
import Factory
import Foundation
import UIKit

// MARK: - BiometricChangeRouterRoutes

@MainActor
public protocol BiometricChangeRouterRoutes: ClosableRoutes, LoginRoutes, BiometricChangeRoutes, ExternalRoutes {}

// MARK: - BiometricChangeRouter

final public class BiometricChangeRouter: Router<UIViewController>, BiometricChangeRouterRoutes {

  // MARK: Lifecycle

  override init() {
    super.init()
    current = NavigationPushOpeningStyle()
  }

  // MARK: Public

  public weak var delegate: BiometricChangeDelegate?

}
