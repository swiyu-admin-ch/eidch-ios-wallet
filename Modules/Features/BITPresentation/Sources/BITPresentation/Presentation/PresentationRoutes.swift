import BITNavigation
import SwiftUI

// MARK: - PresentationRoutes

public protocol PresentationRoutes {
  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws
}

extension PresentationRoutes where Self: RouterProtocol {
  public func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    let viewController: UIViewController
    let style = NavigationPushOpeningStyle()

    if let id = context.inputDescriptorId {
      let module = try CompatibleCredentialsModule(context: context, inputDescriptorId: id)
      module.router.current = style
      module.router.delegate = delegate
      viewController = module.viewController
    } else {
      let module = PresentationRequestReviewModule(context: context)
      module.router.current = style
      module.router.delegate = delegate
      viewController = module.viewController
    }

    open(viewController, on: self.viewController, as: style)
  }
}

// MARK: - PresentationInternalRoutes

protocol PresentationInternalRoutes: ClosableRoutes {
  var delegate: PresentationFinishDelegate? { get set }

  func presentationReview(with context: PresentationRequestContext)
  func presentationResultState(with state: PresentationRequestResultState, context: PresentationRequestContext)
}

extension PresentationInternalRoutes where Self: RouterProtocol {
  func presentationReview(with context: PresentationRequestContext) {
    let viewController = UIHostingController(rootView: PresentationRequestReviewView(context: context, router: self))
    open(viewController, on: self.viewController, as: NavigationPushOpeningStyle())
  }

  func presentationResultState(with state: PresentationRequestResultState, context: PresentationRequestContext) {
    let viewController = UIHostingController(rootView: PresentationRequestResultStateView(state: state, context: context, router: self))
    open(viewController, on: self.viewController, as: NavigationPushOpeningStyle())
  }
}
