import BITAppAuth
import BITCredential
import BITNavigation
import SwiftUI

// MARK: - PresentationRoutes

public protocol PresentationRoutes {
  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws
}

// MARK: - PresentationModuleProtocol

protocol PresentationModuleProtocol: AnyObject {
  var viewController: UIViewController { get }
  var router: PresentationRouter { get }
}

extension PresentationRoutes where Self: RouterProtocol {

  // MARK: Public

  public func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    var module: PresentationModuleProtocol = if context.compatibleCredentials.isEmpty {
      DeclinePresentationModule(context: context)
    } else if context.compatibleCredentials.count > 1 {
      CompatibleCredentialsModule(context: context)
    } else {
      PresentationRequestReviewModule(context: context)
    }

    openModule(module, delegate: delegate)
  }

  // MARK: Private

  private func openModule(_ module: PresentationModuleProtocol, delegate: PresentationFinishDelegate?) {
    let style = NavigationPushOpeningStyle()
    module.router.current = style
    module.router.delegate = delegate
    let viewController = module.viewController

    open(viewController, on: self.viewController, as: style)
  }
}

// MARK: - PresentationInternalRoutes

protocol PresentationInternalRoutes: ClosableRoutes & LoginRoutes {
  var delegate: PresentationFinishDelegate? { get set }

  func badgeInformation(badgeType: BadgeType)
  func presentationReview(with context: PresentationRequestContext)
  func presentationResultState(with state: PresentationRequestResultState, context: PresentationRequestContext)
}

extension PresentationInternalRoutes where Self: RouterProtocol {
  func badgeInformation(badgeType: BadgeType) {
    let view = BadgeInformationView(badgeType: badgeType) { [weak self] in
      self?.dismiss()
    }
    let viewController = UINavigationController(rootViewController: UIHostingController(rootView: view))
    open(viewController, as: ModalOpeningStyle(animatedWhenPresenting: true))
  }

  func presentationReview(with context: PresentationRequestContext) {
    let viewController = UIHostingController(rootView: PresentationRequestReviewView(context: context, router: self))
    open(viewController, on: self.viewController, as: NavigationPushOpeningStyle())
  }

  func presentationResultState(with state: PresentationRequestResultState, context: PresentationRequestContext) {
    let viewController = UIHostingController(rootView: PresentationRequestResultStateView(state: state, context: context, router: self))
    open(viewController, on: self.viewController, as: NavigationPushOpeningStyle())
  }
}
