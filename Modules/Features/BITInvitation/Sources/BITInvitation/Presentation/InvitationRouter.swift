import BITAppAuth
import BITDeeplink
import BITNavigation
import BITPresentation
import Spyable
import UIKit

// MARK: - InvitationRouterRoutes

public protocol InvitationRouterRoutes: ClosableRoutes & CredentialOfferRoutes & ExternalRoutes & InvitationRoutes & PresentationRoutes & LoginRoutes {}

// MARK: - InvitationRouter

final public class InvitationRouter: Router<UIViewController>, InvitationRouterRoutes {}

// MARK: - InvitationDelegate

@Spyable
public protocol InvitationDelegate: AnyObject {
  func didSaveCredential()
  func didDeclineCredential()
}
