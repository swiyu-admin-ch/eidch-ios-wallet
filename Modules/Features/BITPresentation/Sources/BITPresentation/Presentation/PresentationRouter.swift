import BITCredential
import BITNavigation
import UIKit

// MARK: - PresentationRouterRoutes

public protocol PresentationRouterRoutes: ClosableRoutes, PresentationRoutes {}

// MARK: - PresentationRouter

final public class PresentationRouter: Router<UIViewController>, PresentationRouterRoutes, PresentationInternalRoutes {
  public weak var delegate: PresentationFinishDelegate?
}

// MARK: - PresentationFinishDelegate

public protocol PresentationFinishDelegate: AnyObject {
  func retry()
  func cancel()
  func finish(with state: PresentationRequestResultState) async
}
