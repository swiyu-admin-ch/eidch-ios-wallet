import BITHome
import BITInvitation
import BITNavigation
import Foundation
import UIKit

class MockHomeRouter: Router<UIViewController>, HomeRouterRoutes {
  @MainActor
  func invitation(delegate: InvitationDelegate?) {
    if let url = URL(string: "openid-credential-offer://?credential_offer=%7B%22grants%22%3A%7B%22urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Apre-authorized_code%22%3A%7B%22pre-authorized_code%22%3A%2277e1338c-2a9a-48a8-b797-d83318f8d52f%22%7D%7D%2C%22credential_issuer%22%3A%22https%3A%2F%2Fissuer-agent.swiyu.admin.ch%22%2C%22credential_configuration_ids%22%3A%5B%22elfa-sdjwt%22%5D%7D") {
      _ = deeplink(url: url, animated: false)
    }
  }
}
