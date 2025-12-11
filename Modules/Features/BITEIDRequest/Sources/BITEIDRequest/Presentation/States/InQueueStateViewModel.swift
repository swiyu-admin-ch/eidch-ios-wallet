import BITEIDRequestShared
import BITL10n
import Foundation

public class InQueueStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  override init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    guard let onlineSessionStartOpenAt = requestCase.state?.onlineSessionStartOpenAt else {
      throw RequestCaseViewStateError.invalidState
    }

    self.onlineSessionStartOpenAt = onlineSessionStartOpenAt

    try super.init(requestCase: requestCase, delegate: delegate)
  }

  // MARK: Internal

  let onlineSessionStartOpenAt: Date

  var formattedDate: String {
    onlineSessionStartOpenAt.longDateFormat
  }

  var notificationTitle: String {
    if isLegalRepresentantConsentVerified {
      return L10n.tkEidRequestNotificationEidProgressPrimary(fullName)
    }

    return L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueuePrimary
  }

  var notificationContent: String {
    if isLegalRepresentantConsentVerified {
      return L10n.tkEidRequestNotificationEidProgressSecondary(formattedDate)
    }

    return L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueueSecondary
  }

  var notificationType: RequestCaseNotificationView.NotificationType {
    if isLegalRepresentantConsentVerified {
      return .default
    }

    return .primary(label: L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueueButton, action: primaryAction)
  }

  func primaryAction() {
    delegate?.didTapObtainConsent(caseId: id)
  }

}
