import BITEIDRequestShared
import BITL10n

public class AutoVerificationStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  override init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    filesSubmitted = requestCase.filesSubmitted
    try super.init(requestCase: requestCase, delegate: delegate)
  }

  // MARK: Internal

  let filesSubmitted: Bool

  var notificationTitle: String {
    filesSubmitted ? L10n.tkEidRequestNotificationAutoVerificationFilesSubmittedPrimary(fullName) : L10n.tkEidRequestNotificationWalletPairingPrimary
  }

  var notificationContent: String {
    filesSubmitted ? L10n.tkEidRequestNotificationAutoVerificationFilesSubmittedSecondary : L10n.tkEidRequestNotificationWalletPairingSecondary
  }

  var primaryActionLabel: String {
    L10n.tkEidRequestNotificationWalletPairingButton
  }

  func primaryAction() {
    delegate?.didTapIdentityCheck(caseId: id)
  }

}
