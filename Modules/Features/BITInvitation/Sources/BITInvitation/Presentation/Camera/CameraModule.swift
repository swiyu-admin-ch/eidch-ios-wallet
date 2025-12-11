import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CameraModule

@MainActor
public class CameraModule {

  // MARK: Lifecycle

  public init(router: InvitationRouter = Container.shared.invitationRouter(), delegate: InvitationDelegate? = nil) {
    self.router = router
    let viewController = UIHostingController(rootView: CameraView(router: router, delegate: delegate))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Public

  public let viewController: UIViewController
  public var router: InvitationRouter
}
