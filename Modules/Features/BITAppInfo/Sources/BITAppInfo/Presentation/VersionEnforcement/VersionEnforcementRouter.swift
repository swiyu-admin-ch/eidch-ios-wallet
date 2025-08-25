import BITNavigation
import UIKit

// MARK: - VersionEnforcementRoutes

public typealias VersionEnforcementRouterRoutes = ClosableRoutes & ExternalRoutes & VersionEnforcementRoutes

// MARK: - VersionEnforcementRouter

final public class VersionEnforcementRouter: Router<UIViewController>, VersionEnforcementRouterRoutes { }
