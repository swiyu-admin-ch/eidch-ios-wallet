import BITNavigation
import BITPresentation
import Factory
import UIKit


public protocol EIDRequestRouterRoutes: ClosableRoutes & PresentationRoutes & EIDRequestRoutes {}


final public class EIDRequestRouter: Router<UIViewController>, EIDRequestRouterRoutes, EIDRequestInternalRoutes {

  // MARK: Lifecycle

  init(context: EIDRequestContext = Container.shared.eIDRequestContext()) {
    self.context = context
  }

  // MARK: Internal

  var context: EIDRequestContext
}
