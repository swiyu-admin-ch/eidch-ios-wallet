import BITL10n

public class AgentReviewStateViewModel: RequestCaseStateBaseViewModel {

  var notificationTitle: String {
    L10n.tkEidRequestNotificationAgentReviewPrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationAgentReviewSecondary
  }
}
