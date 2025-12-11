import BITL10n
import Factory

public class WalletPairingStateViewModel: RequestCaseStateBaseViewModel {

  var notificationTitle: String {
    L10n.tkEidRequestNotificationWalletPairingPrimary
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationWalletPairingSecondary
  }

  var primaryActionLabel: String {
    L10n.tkEidRequestNotificationWalletPairingButton
  }

  func primaryAction() {
    delegate?.didTapWalletPairing(caseId: id)
  }

}
