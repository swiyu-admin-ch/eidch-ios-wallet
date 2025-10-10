import BITEIDRequestShared
import BITL10n
import Foundation

public class ReadyForOnlineSessionStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    guard let onlineSessionStartTimeoutAt = requestCase.state?.onlineSessionStartTimeoutAt else {
      throw RequestCaseViewStateError.invalidState
    }

    self.onlineSessionStartTimeoutAt = onlineSessionStartTimeoutAt

    try super.init(requestCase: requestCase, delegate: delegate)
  }

  // MARK: Internal

  let onlineSessionStartTimeoutAt: Date

  var formattedDate: String {
    onlineSessionStartTimeoutAt.longDateFormat
  }

  var formattedDateAndTime: String {
    onlineSessionStartTimeoutAt.formatted(
      .dateTime
        .day(.defaultDigits)
        .month(.wide)
        .year()
        .hour(.defaultDigits(amPM: .wide))
        .minute()
        .locale(.current)
    )
  }

  var primaryText: String {
    isLegalRepresentantConsentVerified ? L10n.tkEidRequestNotificationEidReadyPrimary(fullName) : L10n.tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVPrimary
  }

  var secondaryText: String {
    isLegalRepresentantConsentVerified ? L10n.tkEidRequestNotificationEidReadySecondary(formattedDate) : L10n.tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVSecondary(formattedDateAndTime)
  }

  var buttonText: String {
    isLegalRepresentantConsentVerified ? L10n.tkEidRequestNotificationEidReadyGreenButton : L10n.tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVButton
  }

  func primaryAction() {
    if isLegalRepresentantConsentVerified {
      delegate?.didStartAutoVerification(caseId: requestCaseId)
    } else {
      delegate?.didTapObtainConsent(caseId: requestCaseId)
    }
  }

}
