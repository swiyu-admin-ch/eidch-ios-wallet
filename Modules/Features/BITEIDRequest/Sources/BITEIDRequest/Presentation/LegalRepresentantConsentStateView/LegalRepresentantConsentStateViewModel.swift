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
    case .expired: Assets.closeCircle.swiftUIImage
    case .unknown: Assets.closeCircle.swiftUIImage
    }
  }

  var primaryText: String {
    switch state {
    case .inQueue: getInQueueStatePrimaryText()
    case .readyForOnlineSession: getReadyForAVStatePrimaryText()
    case .expired: L10n.tkGetEidLegalRepresentantPendingConsentExpiredPrimary
    case .unknown: ""
    }
  }

  var secondaryText: String {
    switch state {
    case .inQueue: getInQueueStateSecondaryText()
    case .expired: L10n.tkGetEidLegalRepresentantPendingConsentExpiredSecondary
    case .readyForOnlineSession,
         .unknown: ""
    }
  }

  var primaryButtonText: String {
    switch state {
    case .readyForOnlineSession where state.isLegalRepresentantConsentVerified: L10n.tkGetEidLegalRepresentantPendingConsentStartButton
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
    state.isLegalRepresentantConsentVerified ? L10n.tkGetEidConsentOkAvQueuePrimary : L10n.tkGetEidLegalRepresentantPendingConsentInQueuePrimary
  }

  private func getInQueueStateSecondaryText() -> String {
    state.isLegalRepresentantConsentVerified ? L10n.tkGetEidConsentOkAvQueueSecondary : L10n.tkGetEidLegalRepresentantPendingConsentInQueueSecondary
  }

  private func getReadyForAVStatePrimaryText() -> String {
    state.isLegalRepresentantConsentVerified ? L10n.tkGetEidLegalRepresentantGivenConsentReadyForAVPrimary : L10n.tkGetEidLegalRepresentantPendingConsentReadyForAVPrimary
  }
}
