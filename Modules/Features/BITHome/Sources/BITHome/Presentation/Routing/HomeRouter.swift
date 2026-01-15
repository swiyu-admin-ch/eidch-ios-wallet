import BITCredential
import BITEIDRequest
import BITInvitation
import BITNavigation
import BITSettings
import Foundation
import UIKit

// MARK: - HomeRouterRoutes

public protocol HomeRouterRoutes: InvitationRoutes, ExternalRoutes, CredentialDetailRoutes, EIDRequestRoutes, SettingsRoutes, CredentialOfferRoutes {}

// MARK: - HomeRouter

public class HomeRouter: Router<UIViewController>, HomeRouterRoutes {}
