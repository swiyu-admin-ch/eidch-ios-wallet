import BITL10n
import BITTheming
import NavigatorUI

extension PushPermissionViewModel {
  static func errorDataset(retryAction: @escaping (Navigator) -> Void, skipAction: @escaping (Navigator) -> Void) -> ErrorDataset {
    ErrorDataset(
      [
        .title(L10n.tkPushNotificationPermissionErrorTitle),
        .body(L10n.tkPushNotificationPermissionErrorBody),
      ],
      actions: [
        .primary(L10n.tkEidRequestNfcScanErrorButtonRetry, retryAction),
        .secondary(L10n.tkPushNotificationPermissionSecondaryButton, skipAction),
      ])
  }
}
