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
    isLegalRepresentantConsentVerified ? L10n.tkGetEidNotificationEidReadyPrimary(fullName) : L10n.tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVPrimary
  }

  var secondaryText: String {
    isLegalRepresentantConsentVerified ? L10n.tkGetEidNotificationEidReadySecondary(formattedDate) : L10n.tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVSecondary(formattedDateAndTime)
  }

  var buttonText: String {
    isLegalRepresentantConsentVerified ? L10n.tkGetEidNotificationEidReadyGreenButton : L10n.tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVButton
  }

  func primaryAction() {
    if isLegalRepresentantConsentVerified {
      delegate?.didStartAutoVerification(caseId: requestCaseId)
    } else {
      delegate?.didTapObtainConsent(caseId: requestCaseId)
    }
  }

}
