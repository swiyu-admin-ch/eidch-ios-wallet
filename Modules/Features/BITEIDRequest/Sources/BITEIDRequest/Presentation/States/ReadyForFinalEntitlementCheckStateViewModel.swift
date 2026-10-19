import BITL10n

@MainActor
public class ReadyForFinalEntitlementCheckStateViewModel: RequestCaseStateBaseViewModel {

  var notificationTitle: String {
    L10n.tkEidRequestNotificationReadyForFinalEntitlementCheckPrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationReadyForFinalEntitlementCheckSecondary
  }
}
