import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CompatibleCredentialsModule

public class CompatibleCredentialsModule {

  // MARK: Lifecycle

  public init(
    context: PresentationRequestContext,
    inputDescriptorId: String,
    router: PresentationRouter = Container.shared.presentationRouter()) throws
  {
    self.router = router

    guard let compatibleCredentials = context.compatibleCredentialsRequestMap[inputDescriptorId] else {
      throw CompatibleCredentialModuleError.missingCompatibleCredentials
    }

    let viewController = UIHostingController(rootView: CompatibleCredentialView(
      context: context,
      inputDescriptorId: inputDescriptorId,
      compatibleCredentials: compatibleCredentials,
      router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Public

  public let viewController: UIViewController
  public var router: PresentationRouter
}

// MARK: - CompatibleCredentialModuleError

enum CompatibleCredentialModuleError: Error {
  case missingCompatibleCredentials
}
