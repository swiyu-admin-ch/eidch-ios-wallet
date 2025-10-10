import BITL10n
import Factory
import SwiftUI

@MainActor
class LegalRepresentantConsentStateViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, state: RequestCaseViewState) {
    self.router = router
    self.state = state
  }

  // MARK: Internal

  let state: RequestCaseViewState

  var image: Image {
    switch state {
    case .inQueue: Assets.timer.swiftUIImage
    case .readyForOnlineSession: getReadyForAutoVerificationImage()
    case .agentReview,
         .declined,
         .expired,
         .unknown: Assets.closeCircle.swiftUIImage
    }
  }

  var primaryText: String {
    switch state {
    case .inQueue: getInQueueStatePrimaryText()
    case .readyForOnlineSession: getReadyForAVStatePrimaryText()
    case .expired: L10n.tkEidRequestLegalRepresentantPendingConsentExpiredPrimary
    case .agentReview,
         .declined,
         .unknown: ""
    }
  }

  var secondaryText: String {
    switch state {
    case .inQueue: getInQueueStateSecondaryText()
    case .expired: L10n.tkEidRequestLegalRepresentantPendingConsentExpiredSecondary
    case .agentReview,
         .declined,
         .readyForOnlineSession,
         .unknown: ""
    }
  }

  var primaryButtonText: String {
    switch state {
    case .readyForOnlineSession where state.isLegalRepresentantConsentVerified: L10n.tkEidRequestLegalRepresentantPendingConsentStartButton
    default: L10n.tkGlobalClose
    }
  }

  func primaryAction() {
    switch state {
    case .readyForOnlineSession where state.isLegalRepresentantConsentVerified: router.avIdentityCheck()
    default: router.close()
    }
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  private func getReadyForAutoVerificationImage() -> Image {
    state.isLegalRepresentantConsentVerified ? Assets.check.swiftUIImage : Assets.timer.swiftUIImage
  }

  private func getInQueueStatePrimaryText() -> String {
    state.isLegalRepresentantConsentVerified ? L10n.tkEidRequestConsentOkAvQueuePrimary : L10n.tkEidRequestLegalRepresentantPendingConsentInQueuePrimary
  }

  private func getInQueueStateSecondaryText() -> String {
    state.isLegalRepresentantConsentVerified ? L10n.tkEidRequestConsentOkAvQueueSecondary : L10n.tkEidRequestLegalRepresentantPendingConsentInQueueSecondary
  }

  private func getReadyForAVStatePrimaryText() -> String {
    state.isLegalRepresentantConsentVerified ? L10n.tkEidRequestLegalRepresentantGivenConsentReadyForAVPrimary : L10n.tkEidRequestLegalRepresentantPendingConsentReadyForAVPrimary
  }
}
