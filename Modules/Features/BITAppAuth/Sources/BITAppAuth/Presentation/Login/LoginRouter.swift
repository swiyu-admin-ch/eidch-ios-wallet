import BITAppInfo
import BITCore
import BITNavigation
import Factory
import Foundation
import UIKit

// MARK: - LoginRouterRoutes

public protocol LoginRouterRoutes: ClosableRoutes, LoginRoutes, VersionEnforcementRoutes, ExternalRoutes {}

// MARK: - LoginRouter

final public class LoginRouter: Router<UIViewController>, LoginRouterRoutes, ExternalRoutes {}
