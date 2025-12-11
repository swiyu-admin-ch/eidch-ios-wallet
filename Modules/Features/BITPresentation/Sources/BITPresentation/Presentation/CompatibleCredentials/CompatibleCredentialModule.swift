import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CompatibleCredentialsModule

public class CompatibleCredentialsModule {

  // MARK: Lifecycle

  public init(
    context: PresentationRequestContext,
    router: PresentationRouter = Container.shared.presentationRouter()) throws
  {
    self.router = router

    let viewController = UIHostingController(rootView: CompatibleCredentialView(context: context, router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Public

  public let viewController: UIViewController
  public var router: PresentationRouter
}
