import BITL10n

public class IssuingStateViewModel: RequestCaseStateBaseViewModel {

  var notificationTitle: String {
    L10n.tkEidRequestNotificationIssuingPrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationIssuingSecondary
  }
}
