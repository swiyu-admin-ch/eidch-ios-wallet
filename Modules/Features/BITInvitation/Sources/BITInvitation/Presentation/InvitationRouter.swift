import BITAppAuth
import BITDeeplink
import BITNavigation
import BITPresentation
import Spyable
import UIKit

// MARK: - InvitationRouterRoutes

public protocol InvitationRouterRoutes: ClosableRoutes & ExternalRoutes {}

// MARK: - InvitationRouter

final public class InvitationRouter: Router<UIViewController>, InvitationRouterRoutes {}
