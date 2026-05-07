import BITL10n
import BITSettings
import Factory
import Foundation
import SwiftUI

@MainActor
@Observable
class PrivacyPermissionViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func updatePrivacyPolicy(to value: Bool) async {
    router.context.analyticsOptIn = value
    router.pinCodeInformation()
  }

  func openPrivacyPolicy() {
    guard let url = URL(string: L10n.tkOnboardingAnalyticsTertiaryLinkValue) else { return }
    router.openExternalLink(url: url)
  }

  // MARK: Private

  private let router: OnboardingInternalRoutes

}
