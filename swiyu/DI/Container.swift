import Factory
import Foundation

extension Container {
  var overlayWindowCoordinator: Factory<OverlayWindowCoordinating> {
    self { @MainActor in OverlayWindowCoordinator() }
  }

  var loginWindowAnimator: Factory<OverlayWindowAnimating> {
    self { @MainActor in
      LoginWindowDismissalAnimator(duration: 0.3)
    }
  }

  var privacyWindowAnimator: Factory<OverlayWindowAnimating> {
    self { @MainActor in
      PrivacyWindowDismissalAnimator(duration: 0.2)
    }
  }

  var userInactivityTimeout: Factory<TimeInterval> {
    self { 60 * 2 }
  }

  var mamManagedDomain: Factory<String> {
    self { "mam-managed.bit.admin.ch" }
  }

  var trustInfraWildCardDomain: Factory<String> {
    self { "*.trust-infra.swiyu.admin.ch" }
  }

  var trustInfraIntWildCardDomain: Factory<String> {
    self { "*.trust-infra.swiyu-int.admin.ch" }
  }

  var attestationServiceDomain: Factory<String> {
    self { "*.attestations-service.swiyu.admin.ch" }
  }

}
