import BITEIDRequestShared
import BITL10n
import BITNavigation
import Factory
import SwiftUI

@MainActor
@Observable
class LegalRepresentantConsentStateViewModel {

  // MARK: Lifecycle

  init(state: RequestCaseViewState) {
    self.state = state
  }

  // MARK: Internal

  let state: RequestCaseViewState
  var isNavigationCloseTriggered = false
  var destination: EIDRequestDestinations?

  var image: Image {
    switch state {
    case .inQueue: Assets.timer.swiftUIImage
    case .readyForOnlineSession: getReadyForAutoVerificationImage()
    case .agentReview,
         .autoVerification,
         .cancelled,
         .closed,
         .expired,
         .issuing,
         .readyForFinalEntitlementCheck,
         .refused,
         .unknown,
         .walletPairing: Assets.closeCircle.swiftUIImage
    }
  }

  var primaryText: String {
    switch state {
    case .inQueue: getInQueueStatePrimaryText()
    case .readyForOnlineSession: getReadyForAVStatePrimaryText()
    case .expired: L10n.tkEidRequestLegalRepresentantPendingConsentExpiredPrimary
    case .agentReview,
         .autoVerification,
         .cancelled,
         .closed,
         .issuing,
         .readyForFinalEntitlementCheck,
         .refused,
         .unknown,
         .walletPairing: ""
    }
  }

  var secondaryText: String {
    switch state {
    case .inQueue: getInQueueStateSecondaryText()
    case .expired: L10n.tkEidRequestLegalRepresentantPendingConsentExpiredSecondary
    case .agentReview,
         .autoVerification,
         .cancelled,
         .closed,
         .issuing,
         .readyForFinalEntitlementCheck,
         .readyForOnlineSession,
         .refused,
         .unknown,
         .walletPairing: ""
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
    case .readyForOnlineSession where state.isLegalRepresentantConsentVerified:
      destination = .avIdentityCheck(caseId: state.id)
    default:
      close()
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func close() {
    coordinator.cleanup()
    isNavigationCloseTriggered = true
  }

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
